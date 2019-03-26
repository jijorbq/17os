
int strnlen(char *s,int n){
	int len=0;
	while ( s[len] && len<n)++len;
	return len;
}
int strncmp(char *s, char *t, int n){ // string  , template

}
void memcpy(char *dest, char *src, int n);