<%@ Control Language="c#" AutoEventWireup="false" Inherits="NReco.Lucene.LuceneSearchResults" TargetSchema="http://schemas.microsoft.com/intellisense/ie5" %>

<%@ Import Namespace="System" %>
<%@ Import Namespace="System.Collections" %>

<%@ Import Namespace="NReco" %>
<%@ Import Namespace="NReco.Web" %>
<%@ Import Namespace="NReco.Lucene" %>

<%@ Import Namespace="Lucene.Net" %>
<%@ Import Namespace="Lucene.Net.Search" %>
<%@ Import Namespace="Lucene.Net.QueryParsers" %>
<%@ Import Namespace="Lucene.Net.Documents" %>

    <script language="c#" runat="server">
        protected override void OnLoad(EventArgs e)
        {
            base.OnLoad(e);
            DataBind();
        }
		
		protected void Execute_Search(ActionContext context)
		{
			ExecuteSearch();
		}
    
        protected override void BuildQuery()
        {
           // IndexDir = Convert.ToString(WebManager.BasePath);
            var luceneConfiguration = WebManager.GetService<LuceneConfiguration>("luceneConfiguration");
            IndexDir = System.IO.Path.Combine(luceneConfiguration.IndexPath,"companies\\");
            base.BuildQuery();
            string userInput = keywords.Text;
            StringBuilder input = new StringBuilder();
			
			if (!String.IsNullOrEmpty(userInput))
            {
				string[] userKeywords = userInput.Split(new string[] { " " }, StringSplitOptions.RemoveEmptyEntries);
				for (int i = 0; i < userKeywords.Length; ++i)
				{
					string keyword = Convert.ToString(userKeywords[i]);
					input.AppendFormat("(+{0}) OR (\"{0}\") OR ({0}*)", keyword.Trim());
					if (i < userKeywords.Length - 1)
					{
						input.Append(" OR ");
					}
				}
				if (userKeywords.Length > 1)
                {
                    string temp = input.ToString();
                    input = new StringBuilder();
                    input.AppendFormat("({0})", temp);
                }
			}
            string queryText = input.ToString();
            if (queryText.Trim() != String.Empty)
            {
                MultiFieldQueryParser qParser = new MultiFieldQueryParser(new string[] { "CompanyName", "ContactTitle", "ContactName" }, StandardAnalyzer);
                FinalQuery = qParser.Parse(queryText);
            }
        }
		
		private string GetItemValue(int index, string key)
		{
            return (LuceneSearchResultList[index] as Document).Get(key);
		}
    </script>

	<h1>Search</h1>
	
	<table>
		<tr>
			<th>
				<label for="<%= keywords.ClientID %>">Search Keyword(s):</label>
			</th>
			<td>
				<asp:TextBox ID="keywords" Width="500px"
	                runat="server"
	                Text=""
	                />
			</td>
			<td>
			    <asp:LinkButton runat="server" 
				    id="SearchButton" 
				    CommandName="Search" 
				    OnClick="ButtonHandler"
				    CausesValidation="true" 
				    Tooltip="Search" 
				    Text="Search" 
				    CssClass="button" />
			</td>
		</tr>
		<tr>
		    <td>&nbsp;</td>
		    <td colspan="2">
		         <asp:RequiredFieldValidator ID="RequiredFieldValidator1" 
	                        Display="Dynamic"
	                        runat="server" ControlToValidate="keywords" 
	                        ErrorMessage="You must type some keywords before start search!" 
	                        Font-Bold="true" Font-Size="Small" 
	                        />
		    </td>
		</tr>
	</table>

	<h2>Search Results</h2>

	<asp:Placeholder runat="server" Visible='<%# null != LuceneSearchResultList %>'>
		<div class="siteNavPath">
			<span id="ctl00_mainSitePath">
				<strong>Results</strong> <b style="font-size:12px;"><%# null != LuceneSearchResultList ? LuceneSearchResultList.Count : 0 %></b> for <b style="font-size:14px;">'<%# keywords.Text %></b>'. <b><%= SearchTime %></b>
			</span>
		</div>
	</asp:Placeholder>
		<asp:Placeholder runat="server" Visible='<%# null != LuceneSearchResultList ? LuceneSearchResultList.Count == 0 : null == LuceneSearchResultList  %>'>
			Sorry, no entries have been found for the given search request.
		</asp:Placeholder>

		<asp:Repeater id="luceneResultsRepeater" runat="server" DataSource="<%# LuceneSearchResultList %>" Visible="<%# null != LuceneSearchResultList %>">
			<HeaderTemplate>				
				<ol class="SearchResultList">
			</HeaderTemplate>
			<ItemTemplate>		
					<li>
						<div>
							<a title='<%# GetItemValue(Container.ItemIndex, "CompanyName") %>' href='<%# System.IO.Path.Combine(Convert.ToString(WebManager.BasePath) + "/", "CompanyForm.aspx/" + GetItemValue(Container.ItemIndex, "id")) %>'>
								<%# GetItemValue(Container.ItemIndex, "CompanyName") %>
							</a>
						</div>
						<blockquote>
							<strong>Contact Name</strong> : <%# GetItemValue(Container.ItemIndex, "ContactName") %><br />
							<strong>Contact Title</strong> : <%# GetItemValue(Container.ItemIndex, "ContactTitle") %>
						</blockquote>
					</li>
			</ItemTemplate>
			<FooterTemplate>
				</ol>				
			</FooterTemplate>
		</asp:Repeater>
	</asp:Placeholder>