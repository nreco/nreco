using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;

using NReco;
using Lucene.Net.Search;

namespace NReco.Lucene {
	
	public class QueryStringComposer : IProvider<string,string> {

		public string KeywordTemplate { get; set; }
		public string SeparatorTemplate { get; set; }
		public string KeywordSplitRegex { get; set; }

		static Regex LuceneCharsEscape = new Regex("[\\\\+\\-\\!\\(\\)\\:\\^\\]\\{\\}\\~\\*\\?]", RegexOptions.Singleline | RegexOptions.Compiled);

		public QueryStringComposer() {
			KeywordTemplate = "(+{0}) OR ({0}*)";
			SeparatorTemplate = " OR ";
			KeywordSplitRegex = @"[\s\t,.]";
		}

		public virtual string Provide(string keywords) {
			var sb = new StringBuilder();
			string[] userKeywords = Regex.Split(keywords, KeywordSplitRegex, RegexOptions.Singleline);
			foreach (var keyword in userKeywords) {
				var keywordTrimmed = keyword.Trim();
				if (keywordTrimmed.Length>0) {
					if (sb.Length>0)
						sb.Append(SeparatorTemplate);
					sb.AppendFormat(KeywordTemplate, LuceneCharsEscape.Replace(keywordTrimmed, "\\$1" ) );
				}
			}
			return sb.ToString();
		}

	}

}
