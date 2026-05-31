using System;

namespace StringMetrics
{
  public static class Levenshtein
  {
    public static int Distance(string a, string b)
    {
      if (a == null) throw new ArgumentNullException(nameof(a));
      if (b == null) throw new ArgumentNullException(nameof(b));
      var n = a.Length;
      var m = b.Length;
      if (n == 0) return m;
      if (m == 0) return n;
      var d = new int[n + 1, m + 1];
      for (var i = 0; i <= n; i++) d[i, 0] = i;
      for (var j = 0; j <= m; j++) d[0, j] = j;
      for (var i = 1; i <= n; i++)
      {
        for (var j = 1; j <= m; j++)
        {
          var cost = (a[i - 1] == b[j - 1]) ? 0 : 1;
          var delete = d[i - 1, j] + 1;
          var insert = d[i, j - 1] + 1;
          var replace = d[i - 1, j - 1] + cost;
          var min = Math.Min(Math.Min(delete, insert), replace);
          d[i, j] = min;
        }
      }
      return d[n, m];
    }
    public static double Similarity(string a, string b)
    {
      if (a == null) throw new ArgumentNullException(nameof(a));
      if (b == null) throw new ArgumentNullException(nameof(b));
      var distance = Distance(a, b);
      var maxLength = Math.Max(a.Length, b.Length);
      return maxLength == 0 ? 1.0 : 1.0 - (double)distance / maxLength;
    }
  }
  public static class LCS
  {
    public static int Distance(string a, string b)
    {
      if (a == null) throw new ArgumentNullException(nameof(a));
      if (b == null) throw new ArgumentNullException(nameof(b));
      var n = a.Length;
      var m = b.Length;
      if (n == 0) return m;
      if (m == 0) return n;
      var dp = new int[n + 1, m + 1];
      for (var i = 1; i <= n; i++)
      {
        for (var j = 1; j <= m; j++)
        {
          dp[i, j] = a[i - 1] == b[j - 1]
          ? dp[i - 1, j - 1] + 1
          : Math.Max(dp[i - 1, j], dp[i, j - 1]);
        }
      }

      var length = dp[n, m];
      return n + m - (2 * length);
    }
    public static double Similarity(string a, string b)
    {
      if (a == null) throw new ArgumentNullException(nameof(a));
      if (b == null) throw new ArgumentNullException(nameof(b));
      var n = a.Length;
      var m = b.Length;
      if (n == 0 && m == 0) return 1.0;
      var distance = Distance(a, b);
      var maxLength = Math.Max(n, m);
      return 1.0 - (double)distance / maxLength;
    }
  }
}
