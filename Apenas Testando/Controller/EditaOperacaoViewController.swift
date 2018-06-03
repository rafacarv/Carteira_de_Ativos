//
//  EditaOperacaoViewController.swift
//  Apenas Testando
//
//  Created by Rafael C F Leite on 30/12/2017.
//  Copyright © 2017 Rafael C F Leite. All rights reserved.
//

import UIKit
import CoreData


class EditaOperacaoViewController: UIViewController {

    @IBOutlet weak var dataTextField: UITextField!
    @IBOutlet weak var quantidadeTextField: UITextField!
    @IBOutlet weak var precoTextField: UITextField!
    @IBOutlet weak var corretagemTextField: UITextField!
    @IBOutlet weak var issTextField: UITextField!
    @IBOutlet weak var liquidacaoTextField: UITextField!
    @IBOutlet weak var emolumentosTextField: UITextField!
    @IBOutlet weak var irTextField: UITextField!
    @IBOutlet weak var outrasTextField: UITextField!
    
    var dataOperacao = Date()
    
    var cod = String()
    var qty = Int()
    var preco = Float()
    var operacao = String()
    var nome = String()
    var custo = Float()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let formatoData = DateFormatter()
        formatoData.dateFormat = ("dd-mm-yyyy")
        formatoData.locale = Locale(identifier: "pt_BR")
        formatoData.dateStyle = .short
        formatoData.timeStyle = .none
        
        carregaCoreData()
        
        dataTextField.text = formatoData.string(from:dataOperacao)
        quantidadeTextField.text = String(qty)
        precoTextField.text = String(preco)
        corretagemTextField.text = "TBD"
        
    }

    func carregaCoreData() {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let requisicao = NSFetchRequest<NSFetchRequestResult>(entityName: "Operacoes")
        
        let predicate = NSPredicate(format: "data == %@", dataOperacao as CVarArg)
        requisicao.predicate = predicate
        
        do {
            let operacaoBD = try context.fetch(requisicao) as! [NSManagedObject]
            
            for oper in operacaoBD {
                cod = oper.value(forKey: "codigo") as! String
                qty = oper.value(forKey: "quantidade") as! Int
                preco = oper.value(forKey: "preco") as! Float
                operacao = oper.value(forKey: "operacao") as! String
                nome = oper.value(forKey: "nome") as! String
                custo = oper.value(forKey: "custo") as! Float
            }
        }
        catch  {
            print ("Falha ao tentar carregar dados, \(error).")
        }
    }
}
