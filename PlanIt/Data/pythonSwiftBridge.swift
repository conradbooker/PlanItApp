//
//  pythonSwiftBridge.swift
//  PlanIt
//
//  Created by Conrad on 12/31/22.
//

import Foundation
import PythonKit

func runPythonICSJSon(_ URL: String) -> PythonObject {
    let sys = Python.import("sys")
    sys.path.append("/Users/conrad/Documents/projects/PlanIt/PlanIt/Data/icsJSonMain")
    let file = Python.import("icsJSon")
    
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
