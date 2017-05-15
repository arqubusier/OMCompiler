package DumpODE

import interface SimCodeTV;
import ExpressionDumpTpl;

template translateModel(SimCode simCode)
 "Generates graphviz for visiualizing the ode systems."
::=
match simCode
case SIMCODE(modelInfo=modelInfo as MODELINFO(__)) then
  let()= textFile(simulationFile(simCode), '<%fileNamePrefix%>_ODE.dot')
     "" //empty result for true case

end translateModel;



template simulationFile(SimCode simCode)
 "Generates graphviz for visiualizing the ode systems."
::=
match simCode
case SIMCODE(odeEquations=odes) then
  <<
        This is a dump of the ode system
    <%handleOdeEquations(odes)%>
  >>
end simulationFile;

template handleOdeEquations(list<list<SimEqSystem>> odes)
 "OAEU"
::=
<<
    <%
        (odes |> odes2 => (
                '<% ( odes2 |> ode => ('<%handleOde(ode)%>') )%>'
            )
        )
    %>
>>
end handleOdeEquations;

template handleOde(SimEqSystem ode)
 ""
::=
match ode
case SES_SIMPLE_ASSIGN(index=i,cref=ref) then
<<
    ODE!!! index: <%i%> name: <%handleCref(ref)%>
>>
end handleOde;

template handleCref(DAE.ComponentRef ref)
""
::=
    match ref
    case CREF_QUAL(ident=name, componentRef=cref ) then
        '<%name%>.<%handleCref(cref)%>'
    case CREF_IDENT(ident=name) then '<%name%>'
    else "no"
end handleCref;


annotation(__OpenModelica_Interface="backend");
end DumpODE;
