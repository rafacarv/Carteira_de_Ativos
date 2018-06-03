//
//  ConfiguracoesTaxasViewController.swift
//  Apenas Testando
//
//  Created by Rafael C F Leite on 27/05/2018.
//  Copyright © 2018 Rafael C F Leite. All rights reserved.
//

import UIKit

class ConfiguracoesTaxasViewController: UIViewController {

    @IBOutlet weak var CorretagemTF: UITextField!
    @IBOutlet weak var LiquidacaoTF: UITextField!
    @IBOutlet weak var EmolumentosTF: UITextField!
    @IBOutlet weak var ISSTF: UITextField!
    @IBOutlet weak var OutrasTF: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let defaults = UserDefaults.standard
        let check = defaults.string(forKey: "DadosSalvos")
        
        if check != nil{
            let valorCorretagem = defaults.float(forKey: "Corretagem")
            let valorLiquidacao:Float = defaults.float(forKey: "Liquidacao")
            let valorEmolumentos:Float = defaults.float(forKey: "Emolumentos")
            let valorISS:Float = defaults.float(forKey: "ISS")
            let valorOutras:Float = defaults.float(forKey: "Outras")
            
            CorretagemTF.text = String(valorCorretagem)
            LiquidacaoTF.text = String(valorLiquidacao)
            EmolumentosTF.text = String(valorEmolumentos)
            ISSTF.text = String(valorISS)
            OutrasTF.text = String(valorOutras)
        } else {
            CorretagemTF.text = "10"
            LiquidacaoTF.text = "0,0275"
            EmolumentosTF.text = "0,005"
            ISSTF.text = "5"
            OutrasTF.text = "0"
        }
    }
    
    @IBAction func salvaValores(_ sender: Any) {
        print("Botao pressionado. Salvar Coredata")
        
        let defaults = UserDefaults.standard
        let formatter = NumberFormatter()
        formatter.decimalSeparator = ","
        
        defaults.set ("DadosSalvos", forKey: "DadosSalvos")
        
        if let campoCorretagem = CorretagemTF.text {
            if let p = formatter.number(from: campoCorretagem) {
                defaults.set (p, forKey: "Corretagem")
            } else {
                print("Corretagem not parseable")
            }
        }
        if let campoLiquidacao = LiquidacaoTF.text {
            if let p = formatter.number(from: campoLiquidacao) {
                defaults.set (p, forKey: "Liquidacao")
            } else {
                print("Liquidacao not parseable")
            }
        }
        if let campoEmolumentos = EmolumentosTF.text {
            if let p = formatter.number(from: campoEmolumentos) {
                defaults.set (p, forKey: "Emolumentos")
            } else {
                print("Emolumentos not parseable")
            }
        }
        
        if let campoISS = ISSTF.text {
            if let p = formatter.number(from: campoISS) {
                defaults.set (p, forKey: "ISS")
            } else {
                print("ISS not parseable")
            }
        }
        if let campoOutras = OutrasTF.text {
            if let p = formatter.number(from: campoOutras) {
                defaults.set (p, forKey: "Outras")
            } else {
                print("Outras not parseable")
            }
        }
        
        _ = navigationController?.popViewController(animated: true)
        
    }
    
}
