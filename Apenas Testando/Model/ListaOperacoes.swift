//
//  ListaOperacoes.swift
//  Apenas Testando
//
//  Created by Rafael C F Leite on 29/10/2017.
//  Copyright © 2017 Rafael C F Leite. All rights reserved.
//

//import Foundation
import UIKit
import CoreData

class ListaOperacoes {
    
    var listaOperacoes = [Operacao]()
    var carteiraAcoes = [CarteiraDeAcoes]()
    var nomeAtivo : String = ""
    
    init() {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let requisicao = NSFetchRequest<NSFetchRequestResult>(entityName: "Operacoes")
        
        do {
            
            let operacoes = try context.fetch(requisicao)
            
            if operacoes.count > 0 {
               
                for oper in operacoes as! [NSManagedObject] {

                    let cod = oper.value(forKey: "codigo") as! String
                    let qty = oper.value(forKey: "quantidade") as! Int
                    let preco = oper.value(forKey: "preco") as! Float
                    let operacao = oper.value(forKey: "operacao") as! String
                    let data = oper.value(forKey: "data") as! Date
                    let nome = oper.value(forKey: "nome") as! String
                    let custo = oper.value(forKey: "custo") as! Float
     
                    listaOperacoes.append(Operacao(cod: cod, qty: qty, preco: preco, operacao: operacao, data: data, nome: nome, custo: custo))
                }
            } else {
                print("O Modelo esta vazio!")
            }
            ordenaPorData()
        
        } catch {
            print("Falha ao carregar dados do modelo!")
        }
    }
    
    
    func addAcao(cod: String, qty: Int, preco: Float, operacao: String, data: Date, nome: String, custo: Float) {
        listaOperacoes.append(Operacao(cod: cod, qty: qty, preco: preco, operacao: operacao, data: data, nome: nome, custo: custo))
        consolidaAcoes()
        
        // Mark:- Salvamento com persistencia
        //
        // Primeiro instacia appDelegate para acessar os metodos da persistencia
        // Depois cria o "contexto", ataves do metodo do appDelegate
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        // Agora cria a requisição de inserir os objetos na entidade "Operações do modelo
        //
        
        let operacoes = NSEntityDescription.insertNewObject(forEntityName: "Operacoes", into: context)
        
        // Insere os valores para cada chave
        //
        operacoes.setValue(cod, forKey: "codigo")
        operacoes.setValue(qty, forKey: "quantidade")
        operacoes.setValue(preco, forKey: "preco")
        operacoes.setValue(operacao, forKey: "operacao")
        operacoes.setValue(data, forKey: "data")
        operacoes.setValue(nome, forKey: "nome")
        operacoes.setValue(custo, forKey: "custo")
        
        // Salva o contexto
        do {
            try context.save()
            print("Sucesso ao salvar os itens no Model.")
        } catch  {
            print("Falha ao salvar dados.")
        }
        consolidaAcoes()
    }
    
    func consolidaAcoes () {
        
        var ativos : Set<String> = []
        var precoMedio : Float = 0

        carteiraAcoes = []
        ordenaPorData()
        
        for items in listaOperacoes {
            ativos.insert(items.codigoAcao)
        }
        
        for ativo in ativos {
            var qtyTotal: Int = 0
            var custo : Float = 0
            
            for operacao in listaOperacoes {
                if operacao.codigoAcao == ativo {
                    nomeAtivo = operacao.nomeAtivo
                    if operacao.tipoOperacao == "C"{
                        if precoMedio == 0 {
                            precoMedio = operacao.precoUnitario
                        } else {
                            precoMedio = ((precoMedio * Float(qtyTotal)) + (operacao.precoUnitario * Float(operacao.quantidadeAcoes)))/Float((qtyTotal+operacao.quantidadeAcoes))
                        }
                    qtyTotal += operacao.quantidadeAcoes
                    custo += operacao.custoOperacao
                    }
                    else if operacao.tipoOperacao == "V"{
                    qtyTotal -= operacao.quantidadeAcoes
                    custo -= operacao.custoOperacao
                        if qtyTotal == 0 {
                            print("O ativo \(ativo) zerou!")
                            precoMedio = 0
                            custo = 0
                        }
                    }
                }
            }
            if qtyTotal != 0 {
                carteiraAcoes.append(CarteiraDeAcoes(cod: ativo, nome: nomeAtivo, qty: qtyTotal, preco: precoMedio, custo: custo))
            }
        }
    }
    
    func ordenaPorData () {
        
        listaOperacoes.sort(by: { (operacao1, operacao2) -> Bool in
            operacao1.dataOperacao < operacao2.dataOperacao
        })
    }
}
