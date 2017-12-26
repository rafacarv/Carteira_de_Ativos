//
//  CateiraDeAcoes.swift
//  Apenas Testando
//
//  Created by Rafael C F Leite on 03/11/2017.
//  Copyright © 2017 Rafael C F Leite. All rights reserved.
//

import Foundation

class CarteiraDeAcoes {
    
    let codigoAcao : String
    let quantidadeTotal : Int
    let nomeAcao : String
    let precoMedio : Float
    let custoAquisicao : Float
    
    init(cod: String, nome: String, qty: Int, preco: Float, custo: Float ) {
        codigoAcao = cod
        quantidadeTotal = qty
        nomeAcao = nome
        precoMedio = preco
        custoAquisicao = custo
    }
    
}
