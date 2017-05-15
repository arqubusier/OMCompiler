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
    case CLKCONST(__) then "Not Implemented: A"
    case ENUM_LITERAL(__) then "Not Implemented: B"
    case UNARY(__) then "Not Implemented: C"
    case LBINARY(__) then "Not Implemented: D"
    case LUNARY(__) then "Not Implemented: E"
    case RELATION(__) then "Not Implemented: F"
    case IFEXP(__) then "Not Implemented: G"
    case CALL(__) then "Not Implemented: H"
    case RECORD(__) then "Not Implemented: I"
    case PARTEVALFUNCTION(__) then "Not Implemented: J"
    case ARRAY(__) then "Not Implemented: K"
    case MATRIX(__) then "Not Implemented: L"
    case RANGE(__) then "Not Implemented: M"
    case TUPLE(__) then "Not Implemented: N"
    case CAST(__) then "Not Implemented: O"
    case ASUB(__) then "Not Implemented: P"
    case TSUB(__) then "Not Implemented: Q"
    case RSUB(__) then "Not Implemented: R"
    case SIZE(__) then "Not Implemented: S"
    case CODE(__) then "Not Implemented: T"
    case REDUCTION(__) then "Not Implemented: U"
    case LIST(__) then "Not Implemented: V"
    case CONS(__) then "Not Implemented: W"
    case META_TUPLE(__) then "Not Implemented: X"
    case META_OPTION(__) then "Not Implemented: Y"
    case METARECORDCALL(__) then "Not Implemented: Z"
    case MATCHEXPRESSION(__) then "Not Implemented: Å"
    case BOX(__) then "Not Implemented: Ä"
    case UNBOX(__) then "Not Implemented: Ö"
    case SHARED_LITERAL(__) then "Not Implemented: 1"
    case PATTERN(__) then "Not Implemented: 2"
    case SUM(__) then "Not Implemented: 3"
    case BINARY(__) then '<%handleBinary(operator, exp1, exp2)%>'
    case CREF(__) then '<%handleCref(componentRef)%>'
    else "no rhs"
end handleExpression;

template handleBinary(DAE.Operator operator, DAE.Exp exp1, DAE.Exp exp2)
""
::=
    '<%handleExpression(exp1)%> <%binopSymbol(operator)%> <%handleExpression(exp2)%>'
end handleBinary;

template binopSymbol(DAE.Operator operator)
""
::=
    match operator
    case ADD(__) then ' + '
    case SUB(__) then ' - '
    case MUL(__) then ' * '
    case MUL(__) then ' * '
    case DIV(__) then ' / '
end binopSymbol;

annotation(__OpenModelica_Interface="backend");
end DumpODE;
