@echo off
echo >dcc32.cfg /$A-,B-,C-,D+,E-,F-,G+,H+,I-,J+,K-,L+,M-,N+,O+,P-,Q-,R-,S-,T-,U-,V-,W-,X+,Y+,Z-
call b3 -b tcrc16.dpr
::upx -9 tcrc16.exe
