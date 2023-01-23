//
//  pythonSwiftBridge.swift
//  PlanIt
//
//  Created by Conrad on 12/31/22.
//

import Foundation
import PythonKit

func runPythonICSJSon(_ URL: String) -> PythonObject {
    let path = String((Bundle.main.path(forResource: "icsJSon", ofType: "py")!).dropLast(11))
    print(path)
    
    ///private/var/containers/Bundle/Application/0FF83499-223B-4056-818D-0047E20CD79B/PlanIt.app/icsJSon.py

    let sys = Python.import("sys")
    sys.path.append(path)
    let file = Python.import("icsJSon")
    
    //network error handling here
    
    let response = file.returnicsJSon(URL)
    return response
}

func runPyHello() -> PythonObject {
    let sys = Python.import("sys")
    sys.path.append("/Users/conrad/Documents/projects/PlanIt/PlanIt/Data/icsJSonMain")
    let file = Python.import("Example")
    
    let response = file.hello_world()
    return response
}
