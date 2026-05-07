import 'package:flutter/material.dart';
import '../services/app_colors.dart';

class MhwLoading extends StatelessWidget {
  final String mensagem;

  const MhwLoading({super.key, this.mensagem = 'Rastreando monstro...'});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Aqui no futuro você pode trocar por um Image.asset('assets/loading.gif')
          const CircularProgressIndicator(
            color: AppColors.douradoMHW,
            strokeWidth: 3,
          ),
          const SizedBox(height: 20),
          Text(
            mensagem,
            style: const TextStyle(
              color: AppColors.douradoMHW,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}