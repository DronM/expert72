#include <openssl/evp.h>
#include <openssl/bio.h>
#include <openssl/pkcs7.h>

int main(int argc, char **argv)
{
    BIO *data = NULL, *bin = NULL, *bout = NULL;
    PKCS7 *p7, *p7b;

    OpenSSL_add_all_algorithms();

    bin = BIO_new_file("opaque.p7m", "rb");
    p7 = SMIME_read_PKCS7(bin, &data);
    p7b = PKCS7_dup(p7);

    data = PKCS7_dataInit(p7, NULL);

    PKCS7_set_detached(p7b, 1);

    bout = BIO_new_file("detached.p7m", "wb");
    SMIME_write_PKCS7(bout, p7b, data, PKCS7_BINARY | SMIME_DETACHED);
}
