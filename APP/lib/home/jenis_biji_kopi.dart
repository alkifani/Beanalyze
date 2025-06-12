
class JenisKopi {
  final String namaKopi;
  final String jenis;
  final String deskripsi;
  final String harga;
  final List<String> ciriciri;
  final List<String> rasa;
  final List<String> keunggulan;
  final String gambar;

  JenisKopi({
    required this.namaKopi,
    required this.jenis,
    required this.deskripsi,
    required this.harga,
    required this.ciriciri,
    required this.rasa,
    required this.keunggulan,
    required this.gambar,
  });
}

class DataJenisKopi {
  static final List<JenisKopi> kopiList = [
    JenisKopi(
      namaKopi: 'Peaberry',
      jenis: 'Kopi Lanang',
      deskripsi: 'Biji kopi peaberry adalah biji tunggal (single bean) yang muncul jika satu ceri kopi hanya berisi satu biji, bukan dua. Bentuknya bulat seperti kacang polong. Kopi berbiji tunggal termasuk dalam kategori yang langka, hanya sekitar 5–10% dari seluruh buah kopi. Meski ada klaim rasa lebih pekat karena nutrisi terkonsentrasi, industri menilai cita rasa Peaberry berbeda tapi tidak selalu lebih baik daripada biji kopi biasa.',
      harga: 'Karena kelangkaannya, harga peaberry lebih tinggi dibandingkan biji kopi biasa.',
      ciriciri: [
        'Biji kopi yang tumbuh hanya satu di dalam buah kopi',
        'Bentuknya bulat dan lebih kecil dibandingkan biji kopi biasa',
        'Biasa ditemukan pada 5-10% dari seluruh hasil panen kopi',
      ],
      rasa: [
        'Rasa lebih kaya dan kompleks',
        'Keasaman lebih tinggi dan rasa yang lebih intens',
      ],
      keunggulan: [
        'Lebih seragam dalam ukuran dan kualitas',
        'Aromatik dan bertekstur halus',
      ],
      gambar: 'assets/images/peaberry.jpg',
    ),
    JenisKopi(
      namaKopi: 'Longberry',
      jenis: 'Kopi Arabika',
      deskripsi: 'Longberry adalah biji kopi Arabika berukuran lebih besar, pipih dan memanjang. Biji panjang ini biasanya ditemukan dalam persentase tertentu pada varietas tertentu seperti Tim Tim di Gayo. Biji Longberry dijual dengan harga lebih tinggi karena proses penyortirannya yang memakan tenaga. Rasa Longberry mirip kopi Arabika Gayo lainnya dengan konsistensi kematangan yang lebih baik.',
      harga: 'Dikenal dengan harga yang lebih tinggi, terutama untuk kualitas terbaik dari wilayah tertentu.',
      ciriciri: [
        'Bentuknya panjang dan besar',
        'Biji kopi longberry berwarna hijau muda',
        'Ditemukan pada varietas tertentu seperti Tim Tim di Gayo',
      ],
      rasa: [
        'Rasa cerah dan fruity',
        'Keasaman tinggi dan rasa kompleks',
        'Aftertaste bersih dan tajam',
      ],
      keunggulan: [
        'Konsistensi kematangan yang lebih baik',
        'Ukuran biji yang seragam',
      ],
      gambar: 'assets/images/longberry.jpg',
    ),
    JenisKopi(
      namaKopi: 'Defect',
      jenis: 'Kopi Cacat',
      deskripsi: 'Biji kopi defect adalah biji kopi yang tidak sempurna, baik karena kerusakan fisik, cacat dalam pertumbuhan, atau kerusakan selama proses pengolahan. Biji defect memiliki penampilan yang lebih buruk dan mungkin lebih gelap atau lebih kecil.',
      harga: 'Biji kopi defect biasanya lebih murah dibandingkan biji kopi kualitas premium.',
      ciriciri: [
        'Biji kopi pecah, berlubang, atau menghitam',
        'Cacat dalam pertumbuhan atau pengolahan',
        'Penampilan biji lebih buruk dan lebih gelap atau kecil',
      ],
      rasa: [
        'Rasa tidak seimbang',
        'Notes tidak diinginkan seperti asam berlebihan, pahit, atau busuk',
      ],
      keunggulan: [
        'Digunakan untuk campuran atau kopi instan',
        'Harga lebih murah',
      ],
      gambar: 'assets/images/defect.jpg',
    ),
    JenisKopi(
      namaKopi: 'Premium',
      jenis: 'Kopi Grade 1',
      deskripsi: 'Kopi premium adalah biji kopi dengan kualitas terbaik yang dipilih dengan hati-hati dari tanaman kopi yang sehat dan diproses secara teliti. Kopi premium bebas dari cacat atau kerusakan dan memiliki penampilan yang konsisten. Biji kopi ini memiliki rasa yang seimbang dan kompleks, dengan keasaman yang halus.',
      harga: 'Harganya relatif lebih tinggi dibandingkan dengan biji kopi biasa atau defect, tetapi sebanding dengan kualitas rasa yang dihasilkan.',
      ciriciri: [
        'Biji kopi berkualitas tinggi tanpa cacat',
        'Bentuk dan ukuran biji konsisten',
        'Proses pemilihan dan pemrosesan yang cermat',
      ],
      rasa: [
        'Rasa seimbang dan kompleks',
        'Keasaman halus dengan notes buah, bunga, atau cokelat',
      ],
      keunggulan: [
        'Pilihan utama bagi penikmat kopi',
        'Proses yang cermat untuk rasa maksimal',
      ],
      gambar: 'assets/images/premium.jpg',
    ),
  ];
}



