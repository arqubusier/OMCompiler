package DumpODE

import interface SimCodeTV;
import ExpressionDumpTpl;

template translateModel(SimCode simCode)
 "Generates graphviz for visiualizing the ode systems."
::=
match simCode
case SIMCODE(modelInfo=modelInfo as MODELINFO(__)) then
  let()= textFile(simulationFile(simCode, modelInfo), '<%fileNamePrefix%>_ODE.dot')
     "" //empty result for true case

end translateModel;



template simulationFile(SimCode simCode, ModelInfo modelInfo)
 "Generates graphviz for visiualizing the ode systems."
::=
match simCode
case SIMCODE(odeEquations=odes) then
<<
digraph ODE {
  <%handleOdeEquations(odes)%>
  <%handleModelInfo(modelInfo)%>
}
>>
end simulationFile;

template handleModelInfo(ModelInfo modelInfo) ::=
  match modelInfo
  case MODELINFO(vars=SIMVARS(stateVars=stateVars, paramVars=paramVars)) then
  <<
  //    {rank=source; <%(stateVars |> stateVar => '"<%handleSimVar(stateVar)%>" ' )%>}
  //    <%(stateVars |> stateVar => <<
  //                              "euler_$DER.<%handleSimVar(stateVar)%>" -> "<%handleSimVar(stateVar)%>"
  //                              >> )%>
  //    {rank=same; <%(stateVars |> stateVar => '"$DER.<%handleSimVar(stateVar)%>" ' )%>}
    <%(stateVars |> stateVar => <<
                                "$DER.<%handleSimVar(stateVar)%>" -> "euler_$DER.<%handleSimVar(stateVar)%>"
                                "euler_$DER.<%handleSimVar(stateVar)%>" [label="E", shape=box]
                                >> )%>
  //    {rank=sink; <%(stateVars |> stateVar => '"euler_$DER.<%handleSimVar(stateVar)%>" ' )%>}

  <%(paramVars |> paramVar => <<
                             "<%handleSimVar(paramVar)%>" [color=blue]
                             >>)%>
  <%(stateVars |> stateVar => <<
                             "<%handleSimVar(stateVar)%>" [color=red]
                             >>)%>
  >>
  else "No modelInfo!"
end handleModelInfo;

template handleSimVar(SimVar stateVar) ::=
  match stateVar
  case SIMVAR(name=name) then '<%handleCref(name)%>'
  else ""
end handleSimVar;

template handleOdeEquations(list<list<SimEqSystem>> odes)
 "OAEU"
::=
<<
    <%
        (odes |> odes2 => (
			   '<% ( odes2 |> ode hasindex cluster_i => <<
				subgraph cluster_<%cluster_i%>{
				color=blue;
                                <%handleOde(ode)%>
                                }

				>> )%>'
            )
        )
    %>
>>
end handleOdeEquations;

template handleOde(SimEqSystem ode)
 ""
::=
match ode
case SES_SIMPLE_ASSIGN(cref=ref,exp=exp) then
<<

  <%handleExpression(exp)%> "<%handleCref(ref)%>"

>>
end handleOde;

template handleCref(DAE.ComponentRef ref)
""
::=
    match ref
    case CREF_QUAL(ident=name, componentRef=cref, subscriptLst=subLst) then
        '<%name%><%handleSubscriptList(subLst)%>.<%handleCref(cref)%>'
    case CREF_IDENT(ident=name, subscriptLst=subLst) then '<%name%><%handleSubscriptList(subLst)%>'
    else "no lhs"
end handleCref;

template handleSubscriptList(list<Subscript> subLst) ::=
  <<<%(subLst |> subscript => '<%handleSubscript(subscript)%>')%>>>
end handleSubscriptList;

template handleSubscript(Subscript subscript) ::=
  match subscript
  case INDEX(exp=ICONST(integer=integer)) then '[<%integer%>]'
  else ""
end handleSubscript;

//TODO: ENUM_LITERAL CLKCONST
template handleExpression(DAE.Exp exp)
""
::=
    match exp
    case ICONST(__) then '"<%integer%>" ->'
    case RCONST(__) then '"<%real%>" ->'
    case SCONST(__) then '"<%string%>" ->'
    case BCONST(__) then '"<%bool%>" ->'
    case CLKCONST(__) then "Not Implemented: A"
    case ENUM_LITERAL(__) then "Not Implemented: B"
    case LBINARY(__) then "Not Implemented: D"
    case LUNARY(__) then "Not Implemented: E"
    case RELATION(__) then "Not Implemented: F"
    case IFEXP(__) then "Not Implemented: G"
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
    case UNARY(__)  then '<%handleUnary(operator, exp)%>'
    case CREF(__)   then '"<%handleCref(componentRef)%>" ->'
    case CALL(__)   then
      let p = Absyn.pathString(path, ".", false)
      let expLst_ = handleArgumentList(expLst, attr)
      let hash_input = p + expLst_
      let call_unique = p + "_" + stringHashDjb2Mod(hash_input, 1057)
    <<
    <%
      (expLst |> exp => <<
       <%handleExpression(exp)%> <%call_unique%>
       >>)
    %>
    "<%call_unique%>" [label="<%p%>", shape=box]
    "<%call_unique%>" ->
    >>
    else "no rhs"
end handleExpression;

template handleArgumentList(list<Exp> expList, CallAttributes attrs)
""
::=
    <<
    <% (expList |> exp => '<%handleExpression(exp)%>') %>
    >>
end handleArgumentList;

template handleBinary(DAE.Operator operator, DAE.Exp exp1, DAE.Exp exp2)
""
::=
  let exp_1 = handleExpression(exp1)
  let exp_2 = handleExpression(exp2)
  let binop_symbol = binopSymbol(operator)
  let hash_input = exp_1 + binop_symbol + exp_2
  let binop_unique = binop_symbol + "_" + stringHashDjb2Mod(hash_input, 1057)
<<
<%exp_1%> "<%binop_unique%>"[label="op A"]
<%exp_2%> "<%binop_unique%>"
"<%binop_unique%>" [label="<%binop_symbol%>", shape=box]
"<%binop_unique%>" ->
>>
end handleBinary;

template binopSymbol(DAE.Operator operator)
""
::=
    match operator
    case ADD(__)        then '+'
    case SUB(__)        then '-'
    case MUL(__)        then '*'
    case MUL(__)        then '*'
    case DIV(__)        then '/'
    case DIV(__)        then '/'
    case AND(__)        then 'and'
    case OR(__)         then 'or'
    case LESS(__)       then '<'
    case LESSEQ(__)     then '<='
    case GREATER(__)    then '>'
    case GREATEREQ(__)  then '>='
    case EQUAL(__)      then '='
    case NEQUAL(__)     then '/='
    else "UNKNOWN BINARY OPERATOR"

end binopSymbol;

template handleUnary(Operator operator, Exp exp)
""
::=
  let exp_ = handleExpression(exp)
  let unary_symbol = unarySymbol(operator)
  let hash_input = exp_ + unary_symbol
  let unary_unique = unary_symbol + "_" + stringHashDjb2Mod(hash_input, 1057)
<<
<%exp_%> "<%unary_unique%>"
"<%unary_unique%>" [label="<%unary_symbol%>", shape=box]
"<%unary_unique%>" ->
>>
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
