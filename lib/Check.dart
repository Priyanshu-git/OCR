

void _fillLPS(String str, List lps) {
  if (str.length <= 1) return;
  int n = str.length, len = 0;
  lps[0] = 0;
  int i = 1;
  while (i < n) {
    if (str[i] == str[len]) {
      len++;
      lps[i] = len;
      i++;
    } else {
      if (len == 0) {
        lps[i] = 0;
        i++;
      } else {
        len = lps[len - 1];
      }
    }
  }
}

List<String> searchKMP(String text, String pat) {
  int n = text.length;
  int m = pat.length;
  // var map = new Map();
  List<String> list=new List.empty(growable: true);

  List lps = new List.filled(m, 0, growable: false);
  _fillLPS(pat, lps);
  int i = 0, j = 0;
  while (i < n) {
    if (pat[j] == text[i]) {
      i++;
      j++;
    }
    if (j == m) {
      // map[i - j]= m;
      list.add(text.substring(i-j, i-j+m));
      j = lps[j - 1];
    } else if (i < n && pat[j] != text[i]) {
      if (j == 0)
        i++;
      else {
        // map[i - j]= j;
        list.add(text.substring(i-j, i));
        j = lps[j - 1];
      }
    }
  }
  // return map;
  return list;

}
