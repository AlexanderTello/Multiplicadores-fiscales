'***********************************************************************
'*******Multiplicador fiscal de la economía**********************
'++Esquema de Blanchard y Perotti, data mensual

cd "D:\Rethinking"

wfcreate(page = "fiscal") "mensual" m 2006 2021
pagecreate(page = "trim") "trimestral" q 2006 2021

'importamos la base de datos 
pageselect fiscal
import(page=fiscal) "multiplicadores.xlsx" range = "mensuales" @freq m 2006

'--------------------------------------------------------------------------------------------------------
'Creamos el deflactor de la serie del ipc 2007=100
'--------------------------------------------------------------------------------------------------------
series deflactor = 100* IPC/91.8331680833333

'------------------------------------------------------------------------
'Deflactamos las variables nominales
for %b gc gk I
	series N{%b} = {%b}/deflactor
next
'ploteamos la base 

graph g2 ngc ngk nI

'----------------------------------------------------------------------------------------------------------
'Desestacionalizamos las variables que lo requieran
'----------------------------------------------------------------------------------------------------------
for %a ngc ngk nI tc

	{%a}.x13(save="d11"){%a}
	'series {%a}_log=log({%a}_d11)
next

'Copiamos los datos a una hoja trimestral
copy(c=s)  fiscal\n*_d11  trim\*
copy(c=a)  fiscal\ipc  trim\
pageselect trim
'------------------------------------------------------------------------------------------
'                     Loglinealizamos las variables
'------------------------------------------------------------------------------------------
for %a gc gk I

	series n{%a}=log({%a})
next

pageselect trim
import(page=trim) "multiplicadores.xlsx" range = "tri" @freq q 2006

series deflactor = 100* IPC/91.8331680833333


series Npbi= pbi/deflactor

for %a npbi
	{%a}.x13(save="d11"){%a}
	series {%a}_log=log({%a}_d11)
next

graph g1.line(m) ngc ngk ni npbi_log ti 
g1.setelem(1) linecolor(128,0,0) lwidth(1)
g1.setfont all("Arial",9,b) 
g1.save(t=png,d=165) "g1.png"

'-----------------------------------------------------------------------------------------------------------
'Mostramos las variables en tasas de crecimiento anuales
'----------------------------------------------------------------------------------------------------------
series ti_log = log(ti)
for %c ngc ngk ni npbi_log ti_log

series dif_{%c}={%c}-{%c}(-4)

next

graph g2.line(m) dif_ngc dif_ngk dif_ni dif_npbi_log dif_ti_log
g2.setelem(1) linecolor(128,0,0) lwidth(1)
g2.setfont all("Arial",9,b) 
g2.save(t=png,d=165) "g2.png"

pagecreate(page = "var") q 2006 2021
pageselect trim
copy trim\dif_n* var\*
copy trim\dif_ti_log var\ti


pageselect var
pagesave(type=excelxml, mode=update) "diferenciadas.xlsx" range="Diferencias!a1"'como excel
'ESTIMAMOS EL VAR
pageselect var
VAR var_fiscal.ls 1 1 ti gc gk pbi_log i @
var_fiscal.impulse(10,m, se=mc)  pbi_log @ gc gk  i 
freeze(impulsos_respuesta) var_fiscal.impulse(10,t, se=mc) ti gc gk pbi_log i @ ti gc gk pbi_log i 

VAR var_fiscal.ls 1 1 ti gc gk i pbi_log @
var_fiscal.impulse(10,m, se=mc) ti gc gk pbi_log i @ ti gc gk pbi_log i 

'Estimamos un VAR bayesiano
VAR fiscal_bayesiano.bvar(prior=nw) 1 1 ti gc gk i pbi_log @
fiscal_bayesiano.impulse(20,m, imp_resp) PBI_log @ pbi_log gc gk i 
'g1.setelem(1) linecolor(128,0,0) lwidth(1)
'g1.setfont all("Arial",9,b) 
'g1.save(t=png,d=165) "g1.png"
graph01.setelem(1) linecolor(128,0,0) lwidth(1)
graph01.setfont all("Arial",9,b) 
graph01.save(t=png,d=165) "impulse.png"
'VAR var_fiscal.ls 1 2 IPX NGAST_CORR NGAST_CAP PBI_NP NING_CORR @
'var_fiscal.impulse(10,m, se=mc) PBI_NP @ NGAST_CORR NGAST_CAP NING_CORR


