/*********************************************
 * OPL 12.5 Model
 * Author: cholda
 * Creation Date: 10 Dec 2014 at 15:22:09
 *********************************************/

 {string} Nodes = ...;
 
 tuple arc
 {
   string source;
   string destination;
 }   
 
 {arc} Arcs with source in Nodes, destination in Nodes = ...;
 
 tuple demand
 {
   string source;
   string destination;
 }   
 
 {demand} Demands with source in Nodes, destination in Nodes = ...;
 
 {string} NbsO[i in Nodes] = {destination | <i,destination> in Arcs};
 //Set of outgoing neighbors
 
 {string} NbsI[i in Nodes] = {source | <source,i> in Arcs};
 //Set of ingoing neighbors
  
 {string} NodKirch[d in Demands] = Nodes diff {d.source} diff {d.destination};
 //Set of intermediary nodes
  
 float Cost[Arcs] = ...;
  
 dvar float+ x[Arcs][Demands];
  
 minimize sum(a in Arcs,d in Demands) Cost[a]*x[a][d];
  
 subject to{
   
   forall(d in Demands,n in NodKirch[d]) 
   	sum(j in NbsO[n]) x[<n,j>][d] == sum(j in NbsI[n]) x[<j,n>][d];
   	
   forall(d in Demands)
     sum(j in NbsO[d.source]) x[<d.source,j>][d] - sum(j in NbsI[d.source]) x[<j,d.source>][d] == 1;
     
   forall(d in Demands)
     sum(j in NbsO[d.destination]) x[<d.destination,j>][d] - sum(j in NbsI[d.destination]) x[<j,d.destination>][d] == -1;
     
 }