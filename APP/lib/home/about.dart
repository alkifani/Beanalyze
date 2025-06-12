import 'package:beanalyze/configure/constants.dart';
import 'package:beanalyze/home/jenis_biji_kopi.dart';
import 'package:flutter/material.dart';

class About extends StatelessWidget {
  const About({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Macam-Macam Jenis Biji Kopi",
              style: TextStyle(color: Colors.black, fontSize: 20),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: DataJenisKopi.kopiList.length,
              itemBuilder: (context, index) {
                final jeniskopi = DataJenisKopi.kopiList[index];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    color: button,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10),
                          ),
                          child: Image.asset(
                            jeniskopi.gambar, // Gambar diambil dari properti `gambar`
                            width: double.infinity,
                            height: 180,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                child: Text(
                                  jeniskopi.namaKopi,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Jenis: ${jeniskopi.jenis}",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                  // fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                jeniskopi.deskripsi,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                jeniskopi.harga,
                                // textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                  // fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Ciri-Ciri:",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              ...jeniskopi.ciriciri.map((ciriciri) => Text(
                                "- $ciriciri",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                ),
                              )),
                              const SizedBox(height: 8),
                              Text(
                                "Rasa:",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              ...jeniskopi.rasa.map((rasa) => Text(
                                "- $rasa",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                ),
                              )),
                              const SizedBox(height: 8),
                              Text(
                                "Keunggulan:",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              ...jeniskopi.keunggulan.map((keunggulan) => Text(
                                "- $keunggulan",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                ),
                              )),
                              const SizedBox(height: 8),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
