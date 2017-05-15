package DumpODE

import interface SimCodeTV;
import ExpressionDumpTpl;

//type Exp = DAE.Exp;

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
case SES_SIMPLE_ASSIGN(index=i,cref=ref,exp=exp) then
<<
    ODE!!!
    index: <%i%>
    name: <%handleCref(ref)%>
    exp: <%handleExpression(exp)%>

>>
end handleOde;

template handleCref(DAE.ComponentRef ref)
""
::=
    match ref
    case CREF_QUAL(ident=name, componentRef=cref ) then
        '<%name%>.<%handleCref(cref)%>'
    case CREF_IDENT(ident=name) then '<%name%>'
    else "no lhs"
end handleCref;

//TODO: ENUM_LITERAL CLKCONST
template handleExpression(DAE.Exp exp)
""
::=
    match exp
    case ICONST(__) then '<%integer%>'
    case RCONST(__) then '<%real%>'
    case SCONST(__) then '<%string%>'
    case BCONST(__) then '<%bool%>'
    case BINARY(__) then '<%handleBinary(operator, exp1, exp2)%>'
    case UNARY(__)  then '<%handleUnary(operator, exp)%>'
    case CREF(__)   then '<%handleCref(componentRef)%>'
    case CALL(__)   then
    <<
    <%Absyn.pathString(path, '.', false)%>
        (<%handleArgumentList(expLst, attr)%>)'
    >>
    else "no rhs"
end handleExpression;

template handleArgumentList(list<Exp> expList, CallAttributes attrs)
""
::=
    <<
    <% (expList |> exp => '<%handleExpression(exp)%>,') %>
    >>
end handleArgumentList;

template handleBinary(DAE.Operator operator, DAE.Exp exp1, DAE.Exp exp2)
""
::=
    '<%handleExpression(exp1)%> <%binopSymbol(operator)%> <%handleExpression(exp2)%>'
end handleBinary;

template binopSymbol(DAE.Operator operator)
""
::=
    match operator
    case ADD(__)        then ' + '
    case SUB(__)        then ' - '
    case MUL(__)        then ' * '
    case MUL(__)        then ' * '
    case DIV(__)        then ' / '
    case DIV(__)        then ' / '
    case AND(__)        then ' and '
    case OR(__)         then ' or '
    case LESS(__)       then ' < '
    case LESSEQ(__)     then ' <= '
    case GREATER(__)    then ' > '
    case GREATEREQ(__)  then ' >='
    case EQUAL(__)      then ' = '
    case NEQUAL(__)     then ' /= '
    else "UNKNOWN BINARY OPERATOR"

end binopSymbol;

template handleUnary(Operator operator, Exp exp)
""
::=
'<%unarySymbol(operator)%><%handleExpression(exp)%>'

end handleUnary;

template unarySymbol(DAE.Operator operator)
""
::=
    match operator
    case UMINUS(__)     then '-'
    case UMINUS_ARR(__) then '-'
    case NOT(__)        then '!'
    else "UNKNOWN BINARY OPERATOR"
end unarySymbol;

annotation(__OpenModelica_Interface="backend");
end DumpODE;
