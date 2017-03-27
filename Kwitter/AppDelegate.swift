//
//  AppDelegate.swift
//  Kwitter
//
//  Created by Kesley Ribeiro on 12/Mar/17.
//  Copyright © 2017 AppaoCubo. All rights reserved.
//

import UIKit

// Variável global p/ referenciar o AppDelegate e habilitar a chamada via alguma classe
let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate

// Cores
let corAlteradaVermelho = UIColor(red: 245/255, green: 40/255, blue: 40/255, alpha: 1)
let corAlteradaVerde = UIColor(red: 40/255, green: 240/255, blue: 1250/255, alpha: 1)
let corCinza = UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
let corAzul = UIColor(red: 100/255, green: 180/255, blue: 230/255, alpha: 1)

// Tamanhos
let fonteTamanho12 = UIScreen.main.bounds.width / 31

// Guardar todos os dados do usuário atual
var usuario : NSDictionary?

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    // Boolean para verificar se um erro ocorreu ou não
    var mostrarInfoView = false
    
    // Imagem para o background das views Entrar, Registrar e Redefinir senha
    let imagemBakcground = UIImageView()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // Cria imageView para guardar a imagem background 'paisagem.jpg'
        imagemBakcground.frame = CGRect(x: 0, y: 0, width: self.window!.bounds.height * 1.688, height: self.window!.bounds.height)
        imagemBakcground.image = UIImage(named: "paisagem.jpg")
        self.window!.addSubview(imagemBakcground)
        moverBackgroundEsquerda()
        
        // Carregar informações do usuário em var usuario
        usuario = UserDefaults.standard.value(forKey: "parseJSON") as? NSDictionary
        
        // Se existe usuário logado/registrado, mas logado
        if usuario != nil {
                    
            let id = usuario!["id"] as? String
            if id != nil {
                 entrar()
            }
        }

        return true
    }
    
    // Função para animar e mover a imagem do background para esquerda
    func moverBackgroundEsquerda() {
        
        // Iniciar a animação
        UIView.animate(withDuration: 45, animations: {
        
            // Mudar origem da horizontal para criar animação
            self.imagemBakcground.frame.origin.x = -self.imagemBakcground.bounds.width + self.window!.bounds.width
            
        }, completion: { (finalizou:Bool) in
            
            // Se animação finalizar, executar a função moverBackgroundDireita
            if finalizou {
                
                // Mover para direita
                self.moverBackgroundDireita()
            }
        })
    }

    // Função para animar e mover a imagem do background para direita
    func moverBackgroundDireita() {
        
        // Iniciar a animação
        UIView.animate(withDuration: 45, animations: {
        
            // Restaurar origem da horizontal para o padrão normal (0)
            self.imagemBakcground.frame.origin.x = 0

        }, completion: { (finalizou:Bool) in
            
            // Se animação finalizar, executar a função moverBackgroundEsquerda
            if finalizou {

                // Mover para esquerda
                self.moverBackgroundEsquerda()
            }
        })
    }
    
    // Mostrar erro no topo da view
    func infoView(mensagem: String, corAlterada: UIColor) {
        
        // Se mostrarErro não está sendo mostrado
        if mostrarInfoView == false {
           
            // Molde do erroView quando está sendo mostrado ao usuário
            mostrarInfoView = true
            

            // erroView - background vermelho
            let alturaInfoView = self.window!.bounds.height / 14.2
            let infoView_Y = 0 - alturaInfoView
            
            // Criação do background vermelho
            let infoView = UIView(frame: CGRect(x: 0, y: infoView_Y, width: self.window!.bounds.width, height: alturaInfoView))
            infoView.backgroundColor = corAlterada
            self.window!.addSubview(infoView)
            
            
            // Label para mostrar o texto
            let larguraLabelInfo = infoView.bounds.width
            let alturaLabelInfo = infoView.bounds.height + UIApplication.shared.statusBarFrame.height / 2
            
            let infoLabel = UILabel()
            infoLabel.frame.size.width = larguraLabelInfo
            infoLabel.frame.size.height = alturaLabelInfo
            infoLabel.numberOfLines = 0
            
            infoLabel.text = mensagem
            infoLabel.font = UIFont(name: "HelveticaNeue", size: fonteTamanho12)
            infoLabel.textColor = .white
            infoLabel.textAlignment = .center

            infoView.addSubview(infoLabel)
            
            // Animar info view
            UIView.animate(withDuration: 0.3, animations: {                
               
                // Move para baixo o erroView
                infoView.frame.origin.y = 0
                
            }, // Se animação finalizar
               completion: { (finalizado:Bool) in
                
                // Se estiver finalizado
                if finalizado {

                    UIView.animate(withDuration: 0.1, delay: 3, options: .curveLinear, animations: {

                            // Mover para cima o erroView
                            infoView.frame.origin.y = -infoView_Y
                            
                        },  // Se finalizado toda animação
                            completion: { (finalizado:Bool) in
                                
                            if finalizado {
                                infoView.removeFromSuperview()
                                infoLabel.removeFromSuperview()
                                self.mostrarInfoView = false
                        }
                    })
                }
            })
        }
    }
    
    func entrar() {
        
        // Referência para a Main.storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        // armazenar o objeto tabBar a partir do Main.storyboard na var tabBar
        let tabBar = storyboard.instantiateViewController(withIdentifier: "tabBarID")
        
        // Apresentar tabBar que está armazenada na var tabBar
        window?.rootViewController = tabBar
    }        

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

