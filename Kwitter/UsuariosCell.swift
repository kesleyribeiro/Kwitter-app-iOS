//
//  UsuariosCell.swift
//  Kwitter
//
//  Created by Kesley Ribeiro on 23/Mar/17.
//  Copyright © 2017 AppaoCubo. All rights reserved.
//

import UIKit

class UsuariosCell: UITableViewCell {

    // Objetos da view
    @IBOutlet weak var imagemPerfil: UIImageView!
    @IBOutlet weak var nomeUsuarioLabel: UILabel!
    @IBOutlet weak var nomeCompletoLabel: UILabel!
   
    override func awakeFromNib() {
        super.awakeFromNib()

        // Arredondar bordas
        imagemPerfil.layer.cornerRadius = imagemPerfil.bounds.width / 2
        imagemPerfil.clipsToBounds = true
        
        // Cor
        nomeUsuarioLabel.textColor = corAzul
    }
}
