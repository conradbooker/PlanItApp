from icsJSonFinal import returnicsJSon
import pyperclip

returned = returnicsJSon("https://trinityschoolnyc.myschoolapp.com/podium/feed/iCal.aspx?z=HdbCT3ZaWBaxtYaG0jy3COOOHSIw9SwPejVt1ZiRL0e%2f1LkExSAan453LoSYfB4QMIeAjRyRcFPyvvRbCsQ7QA%3d%3d","web")
print(returned)
pyperclip.copy(returned)
