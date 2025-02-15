//  
//  NewTransactionVC.swift
//  BlockChain-Coin
//
//  Created by Maxime Bornemann on 21/03/2018.
//  Copyright © 2018 BLOC.MONEY. All rights reserved.
//

import UIKit
import CenterAlignedCollectionViewFlowLayout
import RxSwift
import RxCocoa
import QRCodeReader

protocol NewTransactionDisplayLogic: class {
    func handleUpdate(viewModel: NewTransactionViewModel)
    func handleWalletsUpdate(viewModel: NewTransactionWalletsViewModel)
}

class NewTransactionVC: ViewController, NewTransactionDisplayLogic, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, QRCodeReaderViewControllerDelegate, CheckPasswordVCDelegate {
    
    let formView = ScrollableStackView()
    let formFields = NewTransactionsFormViews()
    
    let router: NewTransactionRoutingLogic
    let interactor: NewTransactionBusinessLogic
    
    let dataSource = NewTransactionDataSource()
    
    let itemSpacing: CGFloat = 20.0
    
    let disposeBag = DisposeBag()
    
    var lastUpdateForm: NewTransactionForm?
    var form: NewTransactionForm?
    
    lazy var readerVC: QRCodeReaderViewController = {
        let builder = QRCodeReaderViewControllerBuilder {
            $0.reader = QRCodeReader(metadataObjectTypes: [.qr], captureDevicePosition: .back)
        }
        
        return QRCodeReaderViewController(builder: builder)
    }()
    
    let dotBgImageView: UIImageView = {
        let imageView = UIImageView(image: R.image.dotBg())
        imageView.tintColor = UIColor.white.withAlphaComponent(0.3)
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    var shouldResetForm = true
    
    // MARK: - View lifecycle
    
    init() {
        let interactor = NewTransactionInteractor()
        let presenter = NewTransactionPresenter()
        let router = NewTransactionRouter()
        
        self.router = router
        self.interactor = interactor
        
        super.init(nibName: nil, bundle: nil)
        
        interactor.presenter = presenter
        presenter.viewController = self
        router.viewController = self
        
        commonInit()
    }
    
    init(router: NewTransactionRoutingLogic, interactor: NewTransactionBusinessLogic) {
        self.router = router
        self.interactor = interactor
        
        super.init(nibName: nil, bundle: nil)
        
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func commonInit() {
        tabBarItem = UITabBarItem(title: R.string.localizable.tabs_send(), image: R.image.tabBarSend(), selectedImage: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
        
        readerVC.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        resetForm()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        interactor.fetchWallets()
    }

    // MARK: - Configuration
    
    override func configure() {
        super.configure()

        view.backgroundColor = .clear
        
        view.addSubview(formView)
        
        formView.snp.makeConstraints({
            $0.edges.equalToSuperview()
        })
        
        view.insertSubview(dotBgImageView, belowSubview: formView.scrollView)
        
        // Form
        
        formView.stackView.layoutMargins = UIEdgeInsets(top: 0.0, left: 20.0, bottom: 0.0, right: 20.0)
        formView.scrollView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 100.0, right: 0.0)
        formFields.orderedViews.forEach(formView.stackView.addArrangedSubview)
        
        formFields.walletsCollectionView.dataSource = dataSource
        formFields.walletsCollectionView.delegate = self
        
        view.layoutSubviews()
        
        formFields.qrCodeButton.snp.makeConstraints({
            $0.height.equalTo(25.0)
            $0.width.equalTo(formFields.qrCodeButton.intrinsicContentSize.width + formFields.qrCodeButton.imageEdgeInsets.right)
        })
        
        formFields.qrCodeLeftSpacerView.snp.makeConstraints({
            $0.width.equalTo(formFields.qrCodeRightSpacerView.snp.width)
        })
        
        (formFields.walletsCollectionView.collectionViewLayout as? CenterAlignedCollectionViewFlowLayout)?.minimumLineSpacing = itemSpacing / 2.0
        (formFields.walletsCollectionView.collectionViewLayout as? CenterAlignedCollectionViewFlowLayout)?.minimumInteritemSpacing = itemSpacing

        formFields.qrCodeButton.addTarget(self, action: #selector(didTapQRCode), for: .touchUpInside)
        formFields.sendButton.addTarget(self, action: #selector(didTapSend), for: .touchUpInside)
        
        dotBgImageView.snp.makeConstraints({
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(formFields.sendButton.snp.bottom).offset(20.0)
        })

        // Navigation Bar
        
        let titleView = TitleView(title: R.string.localizable.home_menu_send_title(), subtitle: R.string.localizable.home_menu_send_subtitle())
        self.navigationItem.titleView = titleView
        
        let menuButton = UIBarButtonItem(image: R.image.menuIcon(), style: .plain, target: self, action: #selector(menuTapped))
        self.navigationItem.setLeftBarButton(menuButton, animated: false)
        
        // Values
        
        resetForm()
        
        self.interactor.validateForm(request: NewTransactionRequest(form: self.form!))
        
        Observable.combineLatest(formFields.amountTextField.rx.text.asObservable(), formFields.addressTextView.rx.text.asObservable(), formFields.paymentIDTextView.rx.text.asObservable()).subscribe(onNext: { [weak self] amount, address, paymentId in
            let a = amount?.replacingOccurrences(of: ",", with: ".").replacingOccurrences(of: " ", with: "")
            
            self?.updateForm(amount: Double(a ?? ""), address: address, paymentId: paymentId, indexPath: self?.formFields.walletsCollectionView.indexPathsForSelectedItems?.first)
        }).disposed(by: disposeBag)
    }
    
    func updateForm(amount: Double?, address: String?, paymentId: String?, indexPath: IndexPath?) {
        let wallet: WalletModel? = {
            if let wallets = self.dataSource.items.first, let indexPath = indexPath, indexPath.item < wallets.count {
                return wallets[indexPath.item] as? Wallet
            }
            
            return nil
        }()
        
        let form = NewTransactionForm(amount: amount, address: address, sourceWallet: wallet, paymentId: paymentId)
        
        self.form = form
        
        log.info(form)
        
        self.interactor.validateForm(request: NewTransactionRequest(form: form))
    }
    
    func resetForm() {
        guard shouldResetForm == true else { return }
        
        self.formFields.amountTextField.text = nil
        self.formFields.addressTextView.text = nil
        self.formFields.paymentIDTextView.text = nil
        
        self.formFields.amountTextField.rx.text.onNext("")

        self.form = NewTransactionForm(amount: nil, address: nil, sourceWallet: nil, paymentId: nil)
        self.lastUpdateForm = self.form
        
        self.updateForm(amount: nil, address: nil, paymentId: nil, indexPath: nil)
        
        self.updateWalletsList()
    }
    
    // MARK: - Actions
    
    @objc func menuTapped() {
        router.showHome()
    }
    
    @objc func didTapQRCode() {
        shouldResetForm = false
        
        self.present(readerVC, animated: true, completion: nil)
    }
    
    @objc func didTapSend() {
        guard let wallet = form?.sourceWallet, let form = form, form.isValid, let titleView = self.navigationItem.titleView as? TitleView else {
            return
        }
        
        let vc = CheckPasswordVC(wallet: wallet, titleView: titleView, delegate: self)
        present(NavigationController(rootViewController: vc), animated: true, completion: nil)
    }
    
    func didEnterPassword(checkPasswordVC: CheckPasswordVC, string: String) {
        guard let wallet = form?.sourceWallet, let wp = wallet.password, let form = form, form.isValid, string == wp else {
            return
        }
        
        checkPasswordVC.dismiss(animated: true) {
            self.router.showConfirmTransaction(form: form)
        }
    }
    
    // MARK: - UICollectionView delegate
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let count = dataSource.items.first?.count ?? 0

        let sectionInsets = (collectionView.collectionViewLayout as? CenterAlignedCollectionViewFlowLayout)?.sectionInset ?? .zero

        if count == 0 {
            return CGSize(width: collectionView.bounds.width - sectionInsets.left - sectionInsets.right, height: 50.0)
        }
        
        let numberOfItemsPerRow = 3
        let availableWidth = collectionView.bounds.width - (itemSpacing * CGFloat(max(0, numberOfItemsPerRow - 1))) - sectionInsets.left - sectionInsets.right
        let itemWidth = availableWidth / CGFloat(numberOfItemsPerRow)
        return CGSize(width: itemWidth, height: 45.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return itemSpacing / 2.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return itemSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let a = formFields.amountTextField.text?.replacingOccurrences(of: ",", with: ".").replacingOccurrences(of: " ", with: "")

        self.updateForm(amount: Double(a ?? ""), address: formFields.addressTextView.text, paymentId: formFields.paymentIDTextView.text, indexPath: self.formFields.walletsCollectionView.indexPathsForSelectedItems?.first)
    }
    
    // MARK: - UI Update
    
    func handleUpdate(viewModel: NewTransactionViewModel) {
        log.info("State update: \(viewModel.state)")
        
        formFields.sendButton.isEnabled = viewModel.isNextButtonEnabled
        
        updateWalletsList()
    }
    
    func handleWalletsUpdate(viewModel: NewTransactionWalletsViewModel) {
        switch viewModel.state {
        case .loaded(let wallets):
            dataSource.availableWallets = wallets
        default:
            break
        }
        
        updateWalletsList()
    }
    
    fileprivate func updateWalletsList() {
        let validWallets: [WalletModel] = {
            guard let form = form, let amount = form.amount else {
                return dataSource.availableWallets
            }

            return dataSource.availableWallets.filter({
                guard let details = $0.details else {
                    return false
                }
                
                return (details.availableBalance / Constants.walletCurrencyDivider) >= amount
            })
        }()
        
        let count = dataSource.items.first?.count ?? 0
        
        if count == 0 || validWallets.count == count {
            dataSource.items = [ validWallets ]

            let selectedIndexPaths = formFields.walletsCollectionView.indexPathsForSelectedItems
            
            formFields.walletsCollectionView.reloadData()

            if validWallets.count > 0 {
                selectedIndexPaths?.forEach({
                    formFields.walletsCollectionView.selectItem(at: $0, animated: false, scrollPosition: .centeredHorizontally)
                })
            }
        } else {
            dataSource.items = [ validWallets ]

            formFields.walletsCollectionView.performBatchUpdates({
                formFields.walletsCollectionView.reloadSections(IndexSet([0]))
            }, completion: nil)
        }
        
        self.formFields.walletsCollectionView.snp.updateConstraints({
            $0.height.equalTo(self.formFields.walletsCollectionView.collectionViewLayout.collectionViewContentSize.height)
        })
        
        if (lastUpdateForm?.amount ?? 0.0) != (form?.amount ?? 0.0) || validWallets.count == 0 {
            formFields.walletsCollectionView.indexPathsForSelectedItems?.forEach({
                formFields.walletsCollectionView.deselectItem(at: $0, animated: false)
            })
            
            self.form?.sourceWallet = nil
        }
        
        self.lastUpdateForm = self.form
    }
    
    // MARK: - QRCodeReaderViewController Delegate Methods
    
    func reader(_ reader: QRCodeReaderViewController, didScanResult result: QRCodeReaderResult) {
        reader.stopScanning()
        
        formFields.addressTextView.rx.text.asObserver().onNext(result.value)
        formFields.addressTextView.text = result.value
        
        updateForm(amount: form?.amount, address: result.value, paymentId: form?.paymentId, indexPath: formFields.walletsCollectionView.indexPathsForSelectedItems?.first)
        
        reader.dismiss(animated: true) {
            self.shouldResetForm = true
        }
    }
    
    func readerDidCancel(_ reader: QRCodeReaderViewController) {
        reader.stopScanning()
        
        reader.dismiss(animated: true) {
            self.shouldResetForm = true
        }
    }
}
