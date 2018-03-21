#!/bin/bash
read -p "List name which contains all OUTCAR Files names ? > " list
if [ ! -f ${list} ]||[ -z ${list} ]; then
   echo "File not Found.."
   exit
fi
read -p "                  OUTPUT file name to save data ? > " out
read -p "              X plot ( Energy, A, B, C or Vol ) ? > " Xplot
read -p "              Y plot ( Energy, A, B, C or Vol ) ? > " Yplot
read -p "         Calculate the Optimized Value (yes/no) ? > " opt

awk 'BEGIN{printf "# %13s %16s %16s %16s %16s\n","Energy(eV)","A (Ang)","B (Ang)","C (Ang)","Vol. (Ang^3)"}' > ${out}

for i in $(cat $list)
    do
    if [ ! -f $i ]; then
       echo $i " File not Found.."
    else
       grep -A2 "FREE ENERGIE OF THE ION-ELECTRON SYSTEM" $i|awk 'NR==3{printf "%16.8f", $5}' >>${out}
       grep -A10 "VOLUME and BASIS-vectors are now" $i| \
                  awk 'NR==4{vol=$5};\
                       NR==11{printf "%16.8f %16.8f %16.8f %16.8f\n",$1,$2,$3,vol}' >>${out}
    fi
done
echo "All Data are saved to file : " $out


python -c '\
import pylab as p
from scipy.interpolate import interp1d
toplot={ "Energy" : [0,"Energy (eV)","eV"],
         "A"      : [1,"Cell Parameter A ($\AA$)"," $\AA$"],
         "B"      : [2,"Cell Parameter B ($\AA$)"," $\AA$"],
         "C"      : [3,"Cell Parameter C ($\AA$)"," $\AA$"],
         "Vol"    : [4,"Cell Volume ($\AA^3$)"," $\AA^3$"],
       }
data=p.loadtxt("'${out}'")
x=data[:,toplot["'${Xplot}'"][0]]
y=data[:,toplot["'${Yplot}'"][0]]
p.figure(figsize=(10,6))
p.rcParams.update({"font.size": 14})
p.xlabel(toplot["'${Xplot}'"][1])
p.ylabel(toplot["'${Yplot}'"][1])
p.plot(x,y,"r-o")

if "'${opt}'"=="yes":
   xx=p.linspace(x.min(),x.max(),100)
   f=interp1d(x, y, kind="cubic")
   yy=f(xx)
   x_opt=p.around(xx[p.where(yy==yy.min())][0],5)
   y_opt=yy.min()
   p.title("'${Xplot}'$_{min}$ = "+str(x_opt)+toplot["'${Xplot}'"][2], fontsize=20)
   p.plot(x_opt,y_opt,"bo")
p.show()
'
