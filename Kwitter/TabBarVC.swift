//
//  TabBarVC.swift
//  Kwitter
//
//  Created by Kesley Ribeiro on 17/Mar/17.
//  Copyright © 2017 AppaoCubo. All rights reserved.
//

import UIKit

class TabBarVC: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Cor do item na tabBar
        self.tabBar.tintColor = .white

        // Cor do background da tabBar
        self.tabBar.barTintColor = corAzul

        // Desabilitar o translúcido
        self.tabBar.isTranslucent = false

        // Cor do texto abaixo do ícone na tabBar
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: corCinza], for: UIControlState())
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.white], for: .selected)
        
        // Nova cor para os ícones da tabBar
        for item in self.tabBar.items! as [UITabBarItem] {
            if let imagem = item.image {
                item.image = imagem.corImage(corCinza).withRenderingMode(.alwaysOriginal)
            }
        }
        
        // Chamar a função de animação do Kwitter
        animacaoKwitter()
    }
    
    // Animação Kwitter
    func animacaoKwitter() {
        
        // Layer azul
        let layer = UIView() // Declara variável do tipo UIView
        
        layer.frame = self.view.frame // Declara o tamanho size = mesmo tamanho da tela
        layer.backgroundColor = corAzul // Cor da view
        self.view.addSubview(layer) // Adiciona view para view controller
        
        // Ícone Kwitter
        let icone = UIImageView() // Declara variável do tipo UIImageView, p/ armazenar uma imagem
        icone.image = UIImage(named: "Kwitter.png") // Referência para a imagem ser armazenada
        icone.frame.size.width = 100 // Largura da imageview
        icone.frame.size.height = 100 // Altura da imageview
        icone.center = view.center // Centralizar a imageview com o tamanho da tela
        self.view.addSubview(icone) // Adicionar imageview para o view controller

        // Iniciar 1ª animação - zoom out ícone
        UIView.animate(withDuration: 0.5, delay: 1, options: .curveLinear, animations: {
            
            // Fazer um Kwitter pequeno
            icone.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            
        }) { (finalizado:Bool) in
            
            // 1ª função finalizada
            if finalizado {
                
                // 2ª animação - zoom in ícone
                UIView.animate(withDuration: 0.5, animations: {
                    
                    // Fazer um Kwitter grande
                    icone.transform = CGAffineTransform(scaleX: 20, y: 20)
                    
                    // 3ª animação - desaparecer ícone
                    UIView.animate(withDuration: 0.1, delay: 0.3, options: .curveLinear, animations: {
                        
                        // Esconder ícone e layer
                        icone.alpha = 0
                        layer.alpha = 0
                        
                    }, completion: nil)
                })
            }
        }
    }
    
}

// Nova classe para referenciar o ícone na tabBar controller
extension UIImage {
    
    // Esta classe customiza a imagem do ícone
    func corImage(_ cor: UIColor) -> UIImage {
        
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        
        let contexto = UIGraphicsGetCurrentContext()! as CGContext
        contexto.translateBy(x: 0, y: self.size.height)
        contexto.scaleBy(x: 1.0, y: -1.0)

        let rect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height) as CGRect
        contexto.clip(to: rect, mask: self.cgImage!)
        
        cor.setFill()
        contexto.fill(rect)
        
        let imagem = UIGraphicsGetImageFromCurrentImageContext()! as UIImage
        UIGraphicsEndImageContext()

        return imagem
    }
}
