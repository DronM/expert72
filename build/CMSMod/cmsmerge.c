/**
 * gcc -o cmsmerge cmsmerge.c -L/usr/local/lib -lssl -lcrypto
 */
#include <unistd.h>
#include <stdio.h> 
//#include <openssl/evp.h>
#include <openssl/bio.h>
#include <openssl/pkcs7.h>
#include <openssl/pem.h>
#include <openssl/err.h>
#include <openssl/x509.h>

#define ER_CREATE_FILE	"Error opening '%s' file.\n"
#define ER_READ_SMIME	"Error reading '%s' object.\n"
#define ER_NO_SIGN 	"There are no signatures in '%s' data\n"

# define B_FORMAT_TEXT 0x8000
# define FORMAT_BASE64  (3 | B_FORMAT_TEXT)     /* Base64 */
# define FORMAT_ASN1     4                      /* ASN.1/DER */
# define FORMAT_PEM (5 | B_FORMAT_TEXT)

//# define DEBUG 1

int main(int argc, char **argv){
	BIO *source = NULL, *dest = NULL, *out = NULL;
	PKCS7 *p7_s = NULL, *p7_d = NULL;

	STACK_OF(PKCS7_SIGNER_INFO) *signers_s = NULL;
	STACK_OF(X509_INFO) *certs_s = NULL;
	STACK_OF(X509_INFO) *certs_d = NULL;
	
	const EVP_MD		*digest = NULL;//Алгоритм рля расчета хэша сертификатов
	unsigned char		md[EVP_MAX_MD_SIZE];//хэш текущего сертификата для сравнения
	unsigned int		md_n;//длина структуры текущего
	typedef struct md_stack{
		unsigned char md[EVP_MAX_MD_SIZE];
		unsigned int md_len;
		struct md_stack *next;
	} md_stack_t;
	md_stack_t 		*md_stack_head = NULL;
	md_stack_t		*md_stack_cur;
	unsigned int md_diff,md_exists;
	
	
	int i,k;

	int informat = FORMAT_ASN1, outformat = FORMAT_ASN1;//FORMAT_PEM	
	
	char *infile_s = NULL, *infile_d = NULL, *outfile = NULL;
	
	int ret = 1;
	
	while ((i = getopt (argc, argv, "s:d:o:")) != -1)		
		switch (i){
			case 's':
				infile_s = optarg;
				break;
			case 'd':
				infile_d = optarg;
				break;
			case 'o':
				outfile = optarg;
				break;
			case '?':
				if (isprint (i))
					printf("Unknown option `-%c'.\n", i);
				break;
			default:
				abort ();
		}
	
	if(!infile_s) {
		fprintf(stderr, "Source file is not defined.\n");
		goto err;
	}
	if(!infile_d) {
		fprintf(stderr, "Destination file is not defined.\n");
		goto err;
	}
	if(!outfile) {
		fprintf(stderr, "Output file is not defined.\n");
		goto err;
	}
	
	//infile_s = "1.der";
	//infile_d = "2.der";
	//outfile = "out.der";

	OpenSSL_add_all_algorithms();
	ERR_load_BIO_strings();
	ERR_load_crypto_strings();
  	OpenSSL_add_all_digests();
	digest = EVP_get_digestbyname("sha1");

	if ((source = BIO_new_file(infile_s, "rb"))==NULL){
		fprintf(stderr, ER_CREATE_FILE,"source");
		goto err;
	}
	
	if (informat == FORMAT_ASN1)
        	p7_s = d2i_PKCS7_bio(source, NULL);
	else
		p7_s = PEM_read_bio_PKCS7(source, NULL, NULL, NULL);	
		
    	if (p7_s==NULL){
    		fprintf(stderr, ER_READ_SMIME,"source");
    		goto err;
    	}

	if ((dest = BIO_new_file(infile_d, "rb"))==NULL){
		fprintf(stderr, ER_CREATE_FILE,"destination");
		goto err;
	}
	if (informat == FORMAT_ASN1)
        	p7_d = d2i_PKCS7_bio(dest, NULL);
	else
		p7_d = PEM_read_bio_PKCS7(dest, NULL, NULL, NULL);	
	
    	if (p7_d==NULL){
    		fprintf(stderr, ER_READ_SMIME,"destination");
    		goto err;
    	}
	
	
	if ((signers_s = PKCS7_get_signer_info(p7_s))==NULL){
		fprintf(stderr, ER_NO_SIGN,"source");
		goto err;
	}
	
	//merging signers
	PKCS7_SIGNER_INFO *si;
	for (i=0; i < sk_PKCS7_SIGNER_INFO_num(signers_s); i++){
		//add to source
		if ((si = sk_PKCS7_SIGNER_INFO_value(signers_s,i))==NULL){
			printf("Error reading signer with index %d from source signer info!",i);
			exit(-1);
		}
		PKCS7_add_signer(p7_d, si);
	}

	//mergin certificates	
	//dest to stack
	certs_d = p7_d->d.sign->cert;
	i = OBJ_obj2nid(p7_d->type);
	if(i == NID_pkcs7_signed) {
		certs_d = p7_d->d.sign->cert;
	} else if(i == NID_pkcs7_signedAndEnveloped) {
		certs_d = p7_d->d.signed_and_enveloped->cert;
	}	
	for (i = 0; certs_d && i < sk_X509_num(certs_d); i++) {
		X509 *x = sk_X509_value(certs_d,i);
		X509_digest(x, digest, md, &md_n);
		
		#ifdef DEBUG
		printf("Adding dest certs to stack %d, digest=", i);		
		for(k = 0; k < md_n; k++){
			printf("%d",md[k]);
		}
		printf("\n");
		#endif
		
		//add to stack
		if(md_stack_head==NULL){
			//first
			
			#ifdef DEBUG
			printf("Allocating mem for first cert\n");
			#endif
			
			md_stack_head = (md_stack_t *) malloc(sizeof(md_stack_t));
			md_stack_cur = md_stack_head;
		}
		else{
			//get last
			#ifdef DEBUG
			printf("Allocating mem for next item.\n");
			#endif
			
			md_stack_cur->next = (md_stack_t *) malloc(sizeof(md_stack_t));
			md_stack_cur = md_stack_cur->next;
		}
		md_stack_cur->md_len = md_n;
		md_stack_cur->next = NULL;
		for(k = 0; k < md_n; k++){
			md_stack_cur->md[k] = md[k];
		}
	}
	
	
	certs_s = p7_s->d.sign->cert;
	i = OBJ_obj2nid(p7_s->type);
	if(i == NID_pkcs7_signed) {
		certs_s = p7_s->d.sign->cert;
	} else if(i == NID_pkcs7_signedAndEnveloped) {
		certs_s = p7_s->d.signed_and_enveloped->cert;
	}	
	
	for (i = 0; certs_s && i < sk_X509_num(certs_s); i++) {
		X509 *x = sk_X509_value(certs_s,i);
		
		//хэш текущего серта
		X509_digest(x, digest, md, &md_n);
		
		#ifdef DEBUG
		printf("Checking cert %d, digest=", i);
		for(k = 0; k < md_n; k++){
			printf("%d",md[k]);
		}
		printf("\n");
		#endif
		
		//перебор всех		
		md_exists = 0;		
		md_stack_cur = md_stack_head;
		while (md_stack_cur != NULL) {
		
			#ifdef DEBUG
			printf("Comparing with digest=");
			for(k = 0; k < md_stack_cur->md_len; k++){
				printf("%d",md_stack_cur->md[k]);
			}
			printf("\n");
			#endif
			
			md_diff = 0;
			for(k = 0; k < md_n; k++){
				if( (md_n!=md_stack_cur->md_len) || (md[k] != md_stack_cur->md[k]) ){
					#ifdef DEBUG
					printf("Different val\n");
					#endif
					
					md_diff = 1;
					break;
				}
			}
			if(md_diff==0){
				#ifdef DEBUG
				printf("Got same value\n");
				#endif
				
				md_exists = 1;	
				break;
			}
			md_stack_cur = md_stack_cur->next;
		}
		
		#ifdef DEBUG
		printf("Cert already exists=%d\n",md_exists);		
		#endif
		
		if(md_exists==0){
			//add to stack
			if(md_stack_head==NULL){
				//first
				#ifdef DEBUG
				printf("Allocating mem for first cert\n");
				#endif
				
				md_stack_head = (md_stack_t *) malloc(sizeof(md_stack_t));
				md_stack_cur = md_stack_head;
			}
			else{
				//get last
				md_stack_cur = md_stack_head;
				while (md_stack_cur->next != NULL) {
					md_stack_cur = md_stack_cur->next;
				}
				#ifdef DEBUG
				printf("Allocating mem for next item.\n");
				#endif
				md_stack_cur->next = (md_stack_t *) malloc(sizeof(md_stack_t));
				md_stack_cur = md_stack_cur->next;
			}
			md_stack_cur->md_len = md_n;
			md_stack_cur->next = NULL;
			
			#ifdef DEBUG
			printf("Copying digest inf %d\n",md_n);						
			for(k = 0; k < md_n; k++){
				md_stack_cur->md[k] = md[k];
			}									
			printf("Adding cert\n");
			#endif
						
			PKCS7_add_certificate(p7_d, x);
		}
	}	

	out = BIO_new_file(outfile, "wb");
	if (out == NULL){
		fprintf(stderr, "Unable to open output file\n");
		goto err;
	}	
	
	if (outformat == FORMAT_ASN1)
		i = i2d_PKCS7_bio(out, p7_d);
	else
		i = PEM_write_bio_PKCS7(out, p7_d);
	
	i = i2d_PKCS7_bio(out, p7_d);
	if (!i) {		
    		fprintf(stderr, "Unable to write pkcs7 object\n");
    		goto err;
	}
	ret = 0;
 err:	
 	if(md_stack_head!=NULL){
		md_stack_cur = md_stack_head;
		while (md_stack_cur != NULL) {
			md_stack_head = md_stack_cur->next;
			free(md_stack_cur);
			md_stack_cur = md_stack_head;
		}
	}
 
 	if(p7_s){
		PKCS7_free(p7_s);
	}
/*	
	if(p7_d){
		PKCS7_free(p7_d);
	}
*/	
	
	if(certs_s){
		X509_free(certs_s);
	}
	if(certs_d){
		X509_free(certs_d);
	}
	
	if(source){
		BIO_free(source);	
	}
	if(dest){
		BIO_free(dest);
	}
	if(out){
		BIO_free(out);
	}
	
	return ret;
}

