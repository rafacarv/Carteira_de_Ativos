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
        
        //
        // Algumas operaçÕes default para evitar ficar digitando toda vez
        //
        //        let date = Date(timeIntervalSinceReferenceDate: 410220000)
        //        listaOperacoes.append(Operacao(cod: "EMBR3", qty: 200, preco: 20, operacao: "C", data: date, nome: "Embraer", custo: 10))
        //        listaOperacoes.append(Operacao(cod: "EMBR3", qty: 200, preco: 15, operacao: "C", data: date, nome: "Embraer", custo: 11))
        //        listaOperacoes.append(Operacao(cod: "EMBR3", qty: 100, preco: 10, operacao: "V", data: date, nome: "Embraer", custo: 12))
        //        listaOperacoes.append(Operacao(cod: "USIM5", qty: 100, preco: 5, operacao: "C", data: date, nome: "Usiminas", custo: 13))
        //        listaOperacoes.append(Operacao(cod: "USIM5", qty: 100, preco: 8, operacao: "C", data: date, nome: "Usiminas", custo: 14))
        
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
                    
                    print("\(cod) \(qty) \(preco) \(operacao) \(data) \(nome) \(custo)")
                    
                    listaOperacoes.append(Operacao(cod: cod, qty: qty, preco: preco, operacao: operacao, data: data, nome: nome, custo: custo))
                }
                
            }else{
                print("O Modelo esta vazio!")
            }
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
        
    }
    
    func consolidaAcoes () {
        
        var ativos : Set<String> = []
        var precoMedio : Float = 0

        carteiraAcoes = []
        
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
                    qtyTotal = qtyTotal - operacao.quantidadeAcoes
                    custo -= operacao.custoOperacao
                        
                    }
                }
            }
            if qtyTotal != 0 {
                carteiraAcoes.append(CarteiraDeAcoes(cod: ativo, nome: nomeAtivo, qty: qtyTotal, preco: precoMedio, custo: custo))
            } else {
                print("O ativo \(ativo) zerou!")
                precoMedio = 0
                custo = 0
            }
        }
        
        //UserDefaults.standard.set( carteiraAcoes , forKey: "carteira" )
    }
}
