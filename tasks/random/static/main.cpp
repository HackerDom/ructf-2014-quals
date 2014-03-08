// g++ -g3 -ggdb -O0 -DDEBUG -I/usr/include/cryptopp Driver.cpp -o Driver.exe -lcryptopp -lpthread
// g++ -g -O2 -DNDEBUG -I/usr/include/cryptopp Driver.cpp -o Driver.exe -lcryptopp -lpthread

#include <iostream>
using std::cout;
using std::cin;
using std::cerr;
using std::endl;

#include <string>
using std::string;

#include <cstdlib>
using std::exit;

#include "cryptlib.h"
using CryptoPP::Exception;

#include "hex.h"
using CryptoPP::HexEncoder;
using CryptoPP::HexDecoder;

#include "filters.h"
using CryptoPP::StringSink;
using CryptoPP::StringSource;
using CryptoPP::StreamTransformationFilter;

#include "des.h"
using CryptoPP::DES_EDE3;

#include "modes.h"
using CryptoPP::CBC_Mode;

#include "secblock.h"
using CryptoPP::SecByteBlock;

string encrypt_round( const string& key, const string& iv, const string& plain )
{
	string cipher;
	try
	{
	    CBC_Mode< DES_EDE3 >::Encryption e;
	    e.SetKeyWithIV((byte *)key.c_str(), key.size(), (byte *)iv.c_str());
	    // The StreamTransformationFilter adds padding as required. ECB and CBC Mode must be padded to the block size of the cipher.
	    StringSource ss1( plain, true, new StreamTransformationFilter(e, new StringSink(cipher) ) );
	}
	catch(const CryptoPP::Exception& e)
	{
	    cerr << e.what() << endl;
	    exit(1);
	}
	return cipher;
}

string encrypt( const string& key, const string& iv, const string& plain )
{
	string result = plain;
	for (int i = 0; i < 100; i++)
	{
		cout << result.length() << endl;
		result = encrypt_round(key, iv, result);
	}
	return result;
}

void generate_key(string& key, string& iv)
{
	srand(time(0));
	int rbox[8];
	for (int i = 0; i < 20; i++)
	{
		rbox[i] = rand();
	}
	key.assign((char *) &rbox[0], 24);
	iv.assign((char *) &rbox[6], 8);
}

void get_and_save_secret(string key, string iv)
{
	char name[16];
	puts("Please enter your name (16 chars):");
	fgets(name, 16, stdin);
	string secret;
	cout << "Please enter your secret:" << endl;
	cin >> secret;
	secret = encrypt(key, iv, secret);
	int size = secret.size();
	FILE *f = fopen("secret","wb");
	fwrite(name, sizeof(name), 1, f);
	fwrite(&size, 4, 1, f);
	fwrite(secret.c_str(), size, 1, f);
	fclose(f);
}

int main()
{
	string key;
	string iv;
	cout << "Super secure information storage" << endl;
	generate_key(key, iv);
	cout << key.size() << " " << iv.size() << endl;
	cout << "Please remember your key: " << key << iv << endl;
	get_and_save_secret(key, iv);
}