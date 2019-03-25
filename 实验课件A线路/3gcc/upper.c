char Message[10]="AaBbCcDdEe\0";
upper(){
    int i=0;
    while (Message[i]){
        if ( Message[i]>='a' && Message[i]<='z')
            Message[i]=Message[i]+'A'-'a';
        ++i;
    }
}
