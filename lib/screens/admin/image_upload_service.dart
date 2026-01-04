class ImageUrlService {
  static bool isValid(String url) {
    return Uri.tryParse(url)?.hasAbsolutePath == true;
  }

  static String fallback() {
    return 'https://via.placeholder.com/400x250.png?text=Event+Poster';
  }
}
