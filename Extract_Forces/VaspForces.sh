#!/bin/bash

Infos(){
	printf "\nThis bash script allows to extract forces and atoms positions from OUTCAR VASP File.\n"
	printf "The script takes three options :\n"
	printf "\t-outcar : Sets the outcar file name.\n"
	printf "\t-atom   : Sets the Atom number.\n"
	printf "\t-iter   : Sets the Iterations number.\n"
	printf "\t-out    : Sets the output file.\n"
	printf "\t-infos  : Prints infos\n\n"
	printf "For helping : ./VaspForces.sh -h\n" 
	printf "\nAuthor : Hilal Balout\n"
	printf "E-mail : hilal_balout@hotmail.com\n"
} 

Usage () {
	printf "Usage of this script :\n"
	printf "\t-outcar : Sets the outcar file name.\n"
	printf "\t-atom   : Sets the Atom number default value : all atoms.\n"
	printf "\t-iter   : Sets the Iterations number default value : all iterations.\n"
	printf "\t-out    : Sets the output file.\n"
	printf "\t-h      : Print this message. \n"
	printf "\n\tExample:\n\t\t VaspForces.sh -atom=4 -iter=all -outcar=OUTCAR \n"
}
for i in "$@";do
	case $i in
    -atom=*)
    Atom="${i#*=}"
    shift
    ;;
    -iter=*)
    Iter="${i#*=}"
    shift 
    ;;
    -outcar=*)
    Inp="${i#*=}"
    shift
    ;;
    -out=*)
    Out="${i#*=}"
    shift
    ;;
    -infos)
	Infos
	exit 0
	;;
    -h)
	Usage
	exit 0
	esac
done

if [[ -z "${Atom}" ]]; then 
	Atom=all
fi

if [[ -z "${Iter}" ]]; then
	Iter=all
fi

if [[ -z "${Inp}" ]] || [[ ! -f "${Inp}" ]]; then
	printf "\n\t!!!..Error in OUTCAR File Name!\n\n"
	Usage
	exit 0
else
	N_ions=$(grep NIONS ${Inp} |awk '{printf"%d",$NF}')
fi

awk '/TOTAL-FORCE \(eV\/Angst\)/{
	n++
	if (n=='${Iter}'){
			printf("\nN_iteration : %5d\n",n)
			printf("%5s %10s %10s %10s %12s %12s %12s\n","atom","X","Y","Z","Fx","Fy","Fz")		
			for(i=1;i<='${N_ions}';i++){
				getline
				if (i=='${Atom}'){
					printf("%5d %10.5f %10.5f %10.5f %12.6f %12.6f %12.6f\n",i,$1,$2,$3,$4,$5,$6)		
				} else if ("'${Atom}'"=="all") {
					printf("%5d %10.5f %10.5f %10.5f %12.6f %12.6f %12.6f\n",i,$1,$2,$3,$4,$5,$6)
				}
			}
	} else if ("'${Iter}'"=="all"){
		printf("\nN_iteration : %5d\n",n)
		printf("%5s %10s %10s %10s %12s %12s %12s\n","atom","X","Y","Z","Fx","Fy","Fz")		
		for(i=1;i<='${N_ions}';i++){
			getline
			if (i=='${Atom}'){
				printf("%5d %10.5f %10.5f %10.5f %12.6f %12.6f %12.6f\n",i,$1,$2,$3,$4,$5,$6)		
			} else if ("'${Atom}'"=="all") {
				printf("%5d %10.5f %10.5f %10.5f %12.6f %12.6f %12.6f\n",i,$1,$2,$3,$4,$5,$6)
			}
		}

	}
}' ${Inp} |tee  ${Out}