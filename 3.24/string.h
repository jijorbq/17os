
int strnlen(char *s,int n){
	int len=0;
	while ( s[len] && len<n)++len;
	return len;
}
int strncmp(char *s, char *t, int n){ // string  , template
	for (int i=0 ; i<n; ++i)
		if (s[i] != t[i]) return s[i]-t[i];
	return 0;
}
void memcpy(char *dest, char *src, int n){
	for (int i=0; i<n; ++i) dest[i]= src[i];
}