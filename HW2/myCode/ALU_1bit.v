module ALU_1bit( result, carryOut, a, b, invertA, invertB, operation, carryIn, less ); 
  
  output wire result;
  output wire carryOut;
  
  input wire a;
  input wire b;
  input wire invertA;
  input wire invertB;
  input wire[1:0] operation;
  input wire carryIn;
  input wire less;
  
  /*your code here*/ 
  wire aa, bb, w1, w2, w3;

  xor U1(aa, a, invertA);
  xor U2(bb, b, invertB);
  or  U3(w1, aa, bb);
  and U4(w2, aa, bb);
  Full_adder  U5(w3, carryOut, carryIn, aa, bb);

  wire not0, not1, T1, T2, T3, T4;
  not U6(not0, operation[0]);
  not U7(not1, operation[1]);
  and U8(T1, w1, not1, not0);
  and U9(T2, w2, not1, operation[0]); 
  and U10(T3, w3, operation[1], not0); 
  and U11(T4, less, operation[1], operation[0]);
  or  U12(result, T1, T2, T3, T4);

  
endmodule