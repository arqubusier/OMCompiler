package CodegenHDL

import interface SimCodeTV;
import ExpressionDumpTpl;

template translateModel(SimCode simCode)
 "Generates synthesizeable VHDL code for a subset of the modelica language."
::=
match simCode
case SIMCODE(modelInfo=modelInfo as MODELINFO(__)) then
  let()= textFile(simulationFile(simCode), '<%fileNamePrefix%>.vhd')
     "" //empty result for true case

end translateModel;



template simulationFile(SimCode simCode)
 "Generates code for main VHD file for simulation target."
::=
match simCode
case SIMCODE(__) then
  <<
        Hello world HDL

  >>
end simulationFile;



annotation(__OpenModelica_Interface="backend");
end CodegenHDL;
