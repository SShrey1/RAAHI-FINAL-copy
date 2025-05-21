
import UIKit

final class CollectionViewHeaderReusableView: UICollectionReusableView {
    @IBOutlet weak var cellTitleLbl: UILabel!
    
    func setup(_ title: String) {
        cellTitleLbl.text = title
    }
}


//import UIKit
//
//final class CollectionViewHeaderReusableView: UICollectionReusableView {
//    private let cellTitleLbl: UILabel = {
//        let label = UILabel()
//        label.font = .systemFont(ofSize: 18, weight: .bold)
//        label.textColor = .black
//        label.translatesAutoresizingMaskIntoConstraints = false
//        return label
//    }()
//    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        setupUI()
//    }
//    
//    required init?(coder: NSCoder) {
//        super.init(coder: coder)
//        setupUI() // Still support coder, but we’ll rely on programmatic setup
//    }
//    
//    private func setupUI() {
//        addSubview(cellTitleLbl)
//        
//        NSLayoutConstraint.activate([
//            cellTitleLbl.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
//            cellTitleLbl.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
//            cellTitleLbl.topAnchor.constraint(equalTo: topAnchor, constant: 5),
//            cellTitleLbl.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5)
//        ])
//    }
//    
//    func setup(_ title: String) {
//        cellTitleLbl.text = title
//        print("🏷️ Header set to: \(title)") // For debugging
//    }
//}
