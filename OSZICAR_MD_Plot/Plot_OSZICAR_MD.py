#!/usr/bin/python
#-*- coding:utf-8 -*-

import pylab as p


try:
  input = raw_input
except NameError:
  pass

info="T  : is the current temperature.\n\
E  : is the total free energy (including the kinetic energy of the ions and the energy of the Nosé thermostat).\n\
F  : is the total free energy  (at this point the energy of the reference atom has been subtracted).\n\
E0 : is the energy for sigma-> 0 .\n\
EK : is the kinetic energy.\n\
SP : is the potential energy of the Nosé thermostat.\n\
SK : is the corresponding kinetic energy.\n\n\
   more infos : https://cms.mpi.univie.ac.at/vasp/vasp/stdout_OSZICAR_file.html\n"

ff=" as a function of MD Steps"
OSZ_Labels={ "Steps"           : [0," Molecular Dynamic Steps "," (time) "],
             "T"               : [1," Temperature "," (K) ","Temperature"+ff],
             "E"               : [2," Free Energy "," (eV) ","Free Energy"+ff],
             "F"               : [3," Free Energy "," (eV) ","Free Energy"+ff],
             "E0"              : [4," Energy$_{\sigma=0}$ "," (eV) ","Energy $\sigma=0$"+ff ],
             "EK"              : [5," Kinetic Energy "," (eV) ","Kinetic Energy"+ff],
             "SP"              : [6," Potential Energy "," (eV) ","Potential Energy"+ff],
             "SK"              : [7," Corresponding $EK$ "," (eV) ","Corresponding $EK$"+ff]
}

# Molecular Dynamic OSZICAR Reading
def OSZICAR_READ():      
    f=input("          OSZICAR File Name ? > ")
    inp=open(f,"r")
    f=inp.readlines();inp.close()
    DATA=p.array([])
    for i in range(len(f)):
        if "T=" in f[i]:
           info=f[i].split()
           if len(DATA)==0: 
              DATA=p.array([info[::2]],dtype=float) 
           else:
              DATA=p.append(DATA,[p.array(info[::2],dtype=float)],axis=0)   
    return DATA
##

#Plot Data 
def PLOT_DATA(arr,Xplot,Yplot):
    x=arr[:,OSZ_Labels[Xplot][0]]
    y=arr[:,OSZ_Labels[Yplot][0]]
    lb=OSZ_Labels[Yplot][1] 
    print("\n\tMean {} = {} {}\n".format(OSZ_Labels[Yplot][1],p.mean(y),OSZ_Labels[Yplot][2]))
    p.rcParams["font.family"] = "serif"
    p.figure(figsize=(10,6))
    p.rcParams.update({"font.size": 14})
    p.xlabel(OSZ_Labels[Xplot][1]+OSZ_Labels[Xplot][2])
    p.ylabel(OSZ_Labels[Yplot][1]+OSZ_Labels[Yplot][2])
    p.title(OSZ_Labels[Yplot][3])
    p.plot(x,y,"r")
    p.show()
##


OSZ=OSZICAR_READ()
print(info)
PLOT=True
while PLOT:
      #Xplot=input("Xplot (Steps, T, E, F, E0, EK, SP or SK ) > ")
      Xplot="Steps"
      Yplot=input("Yplot (T, E, F, E0, EK, SP or SK ) > ")
      if (Xplot in OSZ_Labels) and (Yplot in OSZ_Labels):
         PLOT_DATA(OSZ,Xplot,Yplot)
      else:
         print("\n    Error in Xplot or Yplot Label!!..\n")
         PLOT=False
      Todo=input("Plot Other Quantities (yes/no)? > ")
      if Todo=="yes":
         PLOT=True
         continue
      else:
         PLOT=False
         print("\n    Exit!..\n")

