import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:pdf/widgets.dart' as pw;


class CvPage extends StatefulWidget {
  @override
  _CvPageState createState() => _CvPageState();
}

class _CvPageState extends State<CvPage> {
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController dateOfBirthController = TextEditingController();
  final TextEditingController nationalityController = TextEditingController();
  final TextEditingController objectiveController = TextEditingController();
  final TextEditingController educationController = TextEditingController();
  final TextEditingController experienceController = TextEditingController();
  final TextEditingController skillsController = TextEditingController();
  final TextEditingController languagesController = TextEditingController();
  final TextEditingController interestsController = TextEditingController();
  final TextEditingController referencesController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Page de création de CV'),
        backgroundColor: Colors.green,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
            const Center(
              child: Text(
                'Compléter votre CV',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: fullNameController,
              labelText: 'Nom complet',
              hintText: 'Ex: Jean Yves',
              prefixIconData: Icons.person,
            ),
            const SizedBox(height: 5),
            _buildTextField(
              controller: addressController,
              labelText: 'Adresse',
              hintText: 'Ex: Lomé, Togo',
              prefixIconData: Icons.location_on,
            ),
            const SizedBox(height: 5),
            _buildTextField(
              controller: phoneNumberController,
              labelText: 'Numéro de téléphone',
              hintText: 'Ex: +228 93816766',
              prefixIconData: Icons.phone,
            ),
            const SizedBox(height: 5),
            _buildTextField(
              controller: emailController,
              labelText: 'Adresse e-mail',
              hintText: 'Ex: jeanyves@example.com',
              prefixIconData: Icons.email,
            ),
            const SizedBox(height: 5),
            _buildTextField(
              controller: dateOfBirthController,
              labelText: 'Date de naissance',
              hintText: 'Ex: 25/08/2003',
              prefixIconData: Icons.date_range,
            ),
            const SizedBox(height: 5),
            _buildTextField(
              controller: nationalityController,
              labelText: 'Nationalité',
              hintText: 'Ex: Togolaise',
              prefixIconData: Icons.account_balance_rounded, //flag
            ),
            const SizedBox(height: 20),
            _buildSectionTitle('Objectif professionnel'),
            _buildTextField(
              controller: objectiveController,
              labelText: 'Décrivez vos objectifs et aspirations professionnelles...',
              maxLines: 4, hintText: '',
            ),
            const SizedBox(height: 20),
            _buildSectionTitle('Formation académique'),
            _buildTextField(
              controller: educationController,
              labelText: 'Indiquez vos diplômes et certifications...',
              maxLines: 4, hintText: '',
            ),
            const SizedBox(height: 20),
            _buildSectionTitle('Expérience professionnelle'),
            _buildTextField(
              controller: experienceController,
              labelText: 'Décrivez vos expériences professionnelles...',
              maxLines: 4, hintText: '',
            ),
            const SizedBox(height: 20),
            _buildSectionTitle('Compétences'),
            _buildTextField(
              controller: skillsController,
              labelText: 'Listez vos compétences...',
              maxLines: 4, hintText: '',
            ),
            const SizedBox(height: 20),
            _buildSectionTitle('Langues'),
            _buildTextField(
              controller: languagesController,
              labelText: 'Indiquez vos langues et votre niveau...',
              maxLines: 4, hintText: '',
            ),
            const SizedBox(height: 20),
            _buildSectionTitle('Centres d\'intérêt'),
            _buildTextField(
              controller: interestsController,
              labelText: 'Listez vos centres d\'intérêt...',
              maxLines: 4, hintText: '',
            ),
            const SizedBox(height: 20),
            _buildSectionTitle('Références'),
            _buildTextField(
              controller: referencesController,
              labelText: 'Donnez le nom et les coordonnées de vos références...',
              maxLines: 4, hintText: '',
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _saveCvToFolder(),
              style: ElevatedButton.styleFrom(
                primary: Colors.green,
                onPrimary: Colors.white,
                textStyle: const TextStyle(fontSize: 18),
                padding: const EdgeInsets.symmetric(vertical: 13.0, horizontal: 24.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: const Text('Générer'),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    int maxLines = 2,
    IconData? prefixIconData,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: prefixIconData != null ? Icon(prefixIconData) : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 20.0),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Future<void> _saveCvToFolder() async {
    try {
      final Uint8List pdfContent = await _generatePdfContent();

      String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

      if (selectedDirectory != null) {
        Directory directory = Directory(selectedDirectory);
        final file = File('${directory.path}/Moncv.pdf');
        await file.writeAsBytes(pdfContent);

        print('CV enregistré avec succès dans ${file.path}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Votre CV a été enregistré avec succès'),
            duration: Duration(seconds: 5),
          ),
        );

        Navigator.pop(context);

      } else {
        print('Aucun répertoire sélectionné.');

        // Show error SnackBar
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Aucun répertoire sélectionné.'),
            duration: Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      print('Erreur lors de la génération du CV: $e');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur lors de la génération du CV.'),
          duration: Duration(seconds: 5),
        ),
      );
    }
  }

  Future<Uint8List> _generatePdfContent() async {
    final pdf = pw.Document();

    final pw.TextStyle titleStyle = pw.TextStyle(
      fontSize: 24,
      fontWeight: pw.FontWeight.bold,
      color: PdfColors.green,
    );
    final pw.TextStyle sectionTitleStyle = pw.TextStyle(
      fontSize: 18,
      fontWeight: pw.FontWeight.bold,
      color: PdfColors.blue,
    );
    final pw.TextStyle infoLabelStyle = pw.TextStyle(
      fontSize: 12,
      fontWeight: pw.FontWeight.bold,
    );
    const pw.TextStyle infoTextStyle = pw.TextStyle(
      fontSize: 12,
    );

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(
                level: 1,
                text: 'Curriculum Vitae',
                textStyle: titleStyle,
              ),
              pw.Divider(),
              pw.SizedBox(height: 10),
              _buildSection('Informations personnelles', style: sectionTitleStyle),
              pw.SizedBox(height: 5),
              _buildInfo('Nom complet: ', fullNameController.text, labelStyle: infoLabelStyle, textStyle: infoTextStyle),
              pw.SizedBox(height: 5),
              _buildInfo('Adresse: ', addressController.text, labelStyle: infoLabelStyle, textStyle: infoTextStyle),
              pw.SizedBox(height: 5),
              _buildInfo('Téléphone: ', phoneNumberController.text, labelStyle: infoLabelStyle, textStyle: infoTextStyle),
              pw.SizedBox(height: 5),
              _buildInfo('Adresse e-mail: ', emailController.text, labelStyle: infoLabelStyle, textStyle: infoTextStyle),
              pw.SizedBox(height: 5),
              _buildInfo('Date de naissance: ', dateOfBirthController.text, labelStyle: infoLabelStyle, textStyle: infoTextStyle),
              pw.SizedBox(height: 5),
              _buildInfo('Nationalité:', nationalityController.text, labelStyle: infoLabelStyle, textStyle: infoTextStyle),
              pw.SizedBox(height: 20),
              _buildSection('Objectif professionnel', style: sectionTitleStyle),
              pw.Text(objectiveController.text),
              pw.SizedBox(height: 20),
              _buildSection('Formation académique', style: sectionTitleStyle),
              pw.Text(educationController.text),
              pw.SizedBox(height: 20),
              _buildSection('Expérience professionnelle', style: sectionTitleStyle),
              pw.Text(experienceController.text),
              pw.SizedBox(height: 20),
              _buildSection('Compétences', style: sectionTitleStyle),
              pw.Text(skillsController.text),
              pw.SizedBox(height: 20),
              _buildSection('Langues', style: sectionTitleStyle),
              pw.Text(languagesController.text),
              pw.SizedBox(height: 20),
              _buildSection('Centres d\'intérêt', style: sectionTitleStyle),
              pw.Text(interestsController.text),
              pw.SizedBox(height: 20),
              _buildSection('Références', style: sectionTitleStyle),
              pw.Text(referencesController.text),
            ],
          );
        },
      ),
    );
    return pdf.save();
  }

  pw.Widget _buildSection(String title, {pw.TextStyle? style}) {
    return pw.Header(
      level: 2,
      text: title,
      textStyle: style,
      decoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(width: 0.5)),
      ),
    );
  }

  pw.Widget _buildInfo(String label, String text, {pw.TextStyle? labelStyle, pw.TextStyle? textStyle}) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          width: 120,
          child: pw.Text(label, style: labelStyle),
        ),
        pw.Expanded(
          child: pw.Text(text, style: textStyle),
        ),
      ],
    );
  }

}