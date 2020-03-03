////
///  SearchToggleButton.swift
//

import SnapKit


class SearchToggleButton: Button {
    private let line = Line()
    override var isSelected: Bool {
        didSet {
            self.updateLineColor()
        }
    }

    override func style() {
        backgroundColor = .background
        titleLabel?.font = .defaultFont()
        setTitleColor(.greyA, for: .normal)
        setTitleColor(.selected, for: .selected)
        updateLineColor()
    }

    override func arrange() {
        addSubview(line)
        line.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalTo(self)
        }
    }

    func setSelected(_ selected: Bool, animated: Bool) {
        elloAnimate(animated: animated) {
            self.isSelected = selected
        }
    }

    private func updateLineColor() {
        line.backgroundColor = isSelected ? .selected : .greyA
    }
}
