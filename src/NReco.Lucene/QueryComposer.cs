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
		static Regex LuceneCharsEscape = new Regex("[\\\\+\\-\\!\\(\\)\\:\\^\\]\\{\\}\\~\\*\\?]", RegexOptions.Singleline | RegexOptions.Compiled);

		public QueryStringComposer() {
			KeywordTemplate = "(+{0}) OR ({0}*)";
			SeparatorTemplate = " OR ";
		}

		public virtual string Provide(string keywords) {
			var sb = new StringBuilder();
			string[] userKeywords = keywords.Split(new[] { ' ', '\t', ',', ';' }, StringSplitOptions.RemoveEmptyEntries);
			for (int i = 0; i < userKeywords.Length; i++) {
				if (i > 0)
					sb.Append(SeparatorTemplate);
				sb.AppendFormat(KeywordTemplate, LuceneCharsEscape.Replace( userKeywords[i].Trim(), "\\$1" ) );
			}
			return sb.ToString();
		}

	}

}
