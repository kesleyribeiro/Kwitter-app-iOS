//
//  PostCell.swift
//  Kwitter
//
//  Created by Kesley Ribeiro on 21/Mar/17.
//  Copyright © 2017 AppaoCubo. All rights reserved.
//

import UIKit

class PostCell: UITableViewCell {

    // Objetos da view
    @IBOutlet weak var nomeUsuarioLabel: UILabel!
    @IBOutlet weak var dataPostLabel: UILabel!
    @IBOutlet weak var textoPostLabel: UILabel!
    @IBOutlet weak var imagemPost: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Cor
        nomeUsuarioLabel.textColor = corAzul

        // Arredondar bordas
        imagemPost.layer.cornerRadius = imagemPost.bounds.width / 20
        imagemPost.clipsToBounds = true
    }    
}
