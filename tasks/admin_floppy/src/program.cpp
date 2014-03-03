#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <time.h>
#include <vector>
#include <algorithm>

class Image {
	char * _image;
	std::vector <int> _free;

	void write_file (const char * name, unsigned short start, unsigned int length) {
		int item = 0;
		while (_image[0x2600 + 0x20 * item])
			++ item;

		memset (& _image[0x2600 + 0x20 * item], 0x00, 32);
		memset (& _image[0x2600 + 0x20 * item], 0x20, 12);
		memcpy (& _image[0x2600 + 0x20 * item], name, std::min (strlen (name), (size_t) 11));
		* (unsigned short *) & _image[0x2600 + 0x20 * item + 0x18] = 0x4468;
		* (unsigned short *) & _image[0x2600 + 0x20 * item + 0x1A] = start;
		* (unsigned int *) & _image[0x2600 + 0x20 * item + 0x1C] = length;
	}

	void write_fat (int number, unsigned short data) {
		int ofs = (3 * number) / 2;
		if (number & 1) {
			* (unsigned short *) & _image[0x200 + ofs] |= (data << 4);
			* (unsigned short *) & _image[0x1400 + ofs] |= (data << 4);
		}
		else {
			* (unsigned short *) & _image[0x200 + ofs] |= data;
			* (unsigned short *) & _image[0x1400 + ofs] |= data;
		}
	}

	unsigned short read_fat (int number) {
		int ofs = (3 * number) / 2;
		if (number & 1)
			return (* (unsigned short *) & _image[0x200 + ofs]) >> 4;

		return (* (unsigned short *) & _image[0x200 + ofs]) & 0x0FFF;
	}

	unsigned short get_empty_fat (unsigned short skip = 0) {
		int result = _free.back ();
		_free.pop_back ();

		return result;
	}

	const char * write_block (int number, const char * data, size_t length) {
		memcpy (& _image[0x3E00 + 0x200 * number], data, std::min (length, (size_t) 0x200));
		return length < 0x200 ? NULL : data + 0x200;
	}

	unsigned short write_file_data (const char * name, char * data, unsigned int length) {
		const char * ptr = data;
		unsigned short r, start = get_empty_fat ();
		write_file (name, r = start, length);

		while (ptr) {
			ptr = write_block (start, ptr, length);
			if (ptr) {
				length -= 0x200;
				unsigned short next = get_empty_fat (start);
				write_fat (start, next);
				start = next;
			}
			else
				write_fat (start, -1);
		}

		return r;
	}

public:
	Image (const char * filename) {
		_image = new char [1474560];

		FILE * fImage = fopen (filename, "rb");
		fread (_image, 1, 1474560, fImage);
		fclose (fImage);

		for (int i = 0; i < 2848; ++ i)
			if (! read_fat (i))
				_free.push_back (i);

		if (! _free.size ())
			return;

		for (int i = 0; i < 10000; ++ i) {
			int x = rand () % _free.size ();
			int y = rand () % _free.size ();
			std::swap (_free[x], _free[y]);
		}
	}

	bool is_full () const {
		return _free.empty ();
	}

	void damage () {
		for (int i = 0x200; i < 0x1400; ++ i)
			if (rand () & 1)
				_image[i] = 0;
			else
				_image[0x1200 + i] = 0;

		memset (& _image[0x2600], 0, 0x1C00);
	}

	void restore () {
		for (int i = 0x200; i < 0x1400; ++ i) {
			char x = _image[i] | _image[0x1200 + i];
			_image[i] = _image[0x1200 + i] = x;
		}
	}

	unsigned short write_random_file () {
		long size = 16384 + rand () % 16384;
		if (512 * _free.size () <= size)
			return 0;

		char * data = new char [size];
		for (int i = 0; i < size; ++ i)
			data [i] = rand ();

		unsigned short s = write_file_data ("XXX", data, size);

		delete [] data;

		return s;
	}

	unsigned short write_from_file (const char * name) {
		FILE * f = fopen (name, "rb");
		
		fseek (f, 0, SEEK_END);
		long size = ftell (f);
		rewind (f);

		char * data = new char [size];
		fread (data, 1, size, f);
		fclose (f);

		unsigned short s = write_file_data (name, data, size);

		delete [] data;

		return s;
	}

	void dump (const char * filename) {
		FILE * fImage = fopen (filename, "wb");
		fwrite (_image, 1, 1474560, fImage);
		fclose (fImage);
	}

	~Image () {
		delete [] _image;
	}
};

int main () {
	srand (time (NULL));
	
	Image img ("empty.ima");
	printf ("answer at %d\n", img.write_from_file ("ANSWER  JPG"));
	
	for (int i = 0; i < 80; ++ i)
		img.write_random_file ();

	img.damage ();
	img.dump ("task.ima");
	
/*
	Image img ("task.ima");
	img.restore ();
	img.dump ("recov.ima");
*/
	return 0;
}
