using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

using NReco;
using Lucene.Net.Search;

namespace NReco.Lucene {
	
	public class QueryStringComposer : IProvider<string,string> {

		public string KeywordTemplate { get; set; }
		public string SeparatorTemplate { get; set; }

		public QueryStringComposer() {
			KeywordTemplate = "(+{0}) OR (\"{0}\") OR ({0}*)";
			SeparatorTemplate = " OR ";
		}

		public string Provide(string keywords) {
			var sb = new StringBuilder();
			string[] userKeywords = keywords.Split(new string[] { " " }, StringSplitOptions.RemoveEmptyEntries);
			for (int i = 0; i < userKeywords.Length; i++) {
				if (i > 0)
					sb.Append(SeparatorTemplate);
				sb.AppendFormat(KeywordTemplate, userKeywords[i].Trim());
			}
			return sb.ToString();
		}

	}

}
