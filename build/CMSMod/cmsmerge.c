/*
 * gcc -o cmsmerge cmsmerge.c -lssl -lcrypto
 */
#include <unistd.h>
#include <stdio.h> 
#include <openssl/evp.h>
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

int main(int argc, char **argv){
	BIO *source = NULL, *dest = NULL, *out = NULL;
	PKCS7 *p7_s, *p7_d;

	STACK_OF(PKCS7_SIGNER_INFO) *signers_s = NULL;
	STACK_OF(X509_INFO) *certs_s = NULL;
	
	int i,n;

	int informat = FORMAT_ASN1, outformat = FORMAT_ASN1;//FORMAT_PEM	
	
	char *infile_s = NULL, *infile_d = NULL, *outfile = NULL;
	
	int c;
	while ((c = getopt (argc, argv, "s:d:o:")) != -1)		
		switch (c){
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
				if (isprint (c))
					printf("Unknown option `-%c'.\n", c);
				break;
			default:
				abort ();
		}
	
	if(!infile_s) {
		printf("Source file is not defined.\n");
		exit(-1);
	}
	if(!infile_d) {
		printf("Destination file is not defined.\n");
		exit(-1);
	}
	if(!outfile) {
		printf("Output file is not defined.\n");
		exit(-1);
	}
	
	//infile_s = "1.der";
	//infile_d = "2.der";
	//outfile = "out.der";

	OpenSSL_add_all_algorithms();
	ERR_load_BIO_strings();
	ERR_load_crypto_strings();
  
	if ((source = BIO_new_file(infile_s, "rb"))==NULL){
		printf(ER_CREATE_FILE,"source");
		ERR_print_errors_fp(stderr);
		exit(-1);
	}
	
	if (informat == FORMAT_ASN1)
        	p7_s = d2i_PKCS7_bio(source, NULL);
	else
		p7_s = PEM_read_bio_PKCS7(source, NULL, NULL, NULL);	
		
    	if (p7_s==NULL){
    		printf(ER_READ_SMIME,"source");
    		ERR_print_errors_fp(stderr);
    		exit(-1);
    	}

	if ((dest = BIO_new_file(infile_d, "rb"))==NULL){
		printf(ER_CREATE_FILE,"destination");
		ERR_print_errors_fp(stderr);
		exit(-1);
	}
	if (informat == FORMAT_ASN1)
        	p7_d = d2i_PKCS7_bio(dest, NULL);
	else
		p7_d = PEM_read_bio_PKCS7(dest, NULL, NULL, NULL);	
	
    	if (p7_d==NULL){
    		printf(ER_READ_SMIME,"destination");
    		ERR_print_errors_fp(stderr);
    		exit(-1);
    	}
	
	
	if ((signers_s = PKCS7_get_signer_info(p7_s))==NULL){
		printf(ER_NO_SIGN,"source");
		ERR_print_errors_fp(stderr);
		exit(1);
	}
	
	//merging signers
	PKCS7_SIGNER_INFO *si;
	n = sk_PKCS7_SIGNER_INFO_num(signers_s);
	for (i=0; i<n; i++){
		//add to source
		if ((si = sk_PKCS7_SIGNER_INFO_value(signers_s,i))==NULL){
			printf("Error reading signer with index %d from source signer info!",i);
			exit(-1);
		}
		PKCS7_add_signer(p7_d, si);
	}

	//mergin certificates
	certs_s = p7_s->d.sign->cert;
	i = OBJ_obj2nid(p7_s->type);
	if(i == NID_pkcs7_signed) {
		certs_s = p7_s->d.sign->cert;
	} else if(i == NID_pkcs7_signedAndEnveloped) {
		certs_s = p7_s->d.signed_and_enveloped->cert;
	}	
	n = sk_X509_num(certs_s);
	for (i = 0; certs_s && i < n; i++) {
		X509 *x = sk_X509_value(certs_s,i);
		PKCS7_add_certificate(p7_d, x);
	}	

	out = BIO_new_file(outfile, "wb");
	if (out == NULL){
		printf("Unable to open output file\n");
		ERR_print_errors_fp(stderr);
		exit(-1);
	}	
	
	if (outformat == FORMAT_ASN1)
		i = i2d_PKCS7_bio(out, p7_d);
	else
		i = PEM_write_bio_PKCS7(out, p7_d);
	
	i = i2d_PKCS7_bio(out, p7_d);
	if (!i) {
    		printf("Unable to write pkcs7 object\n");
    		ERR_print_errors_fp(stderr);
		exit(-1);
	}
	
	/*
	BIO_free(source);	
	BIO_free(dest);
	if (out != NULL)
		BIO_free(out);
	
	PKCS7_free(p7_s);
	PKCS7_free(p7_d);
	*/
	return 0;
}

