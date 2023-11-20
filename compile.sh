#!/bin/sh
as CallRet.asm -o CallRet.o -g
ld CallRet.o -o CallRet
as Exp7.asm -o Exp7.o -g
ld Exp7.o -o Exp7