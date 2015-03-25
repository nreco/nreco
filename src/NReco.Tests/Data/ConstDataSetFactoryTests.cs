using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using NReco.Converting;
using System.Data;

using NUnit.Framework;
using NReco.Dsm.Composition;

using NReco.Dsm.Data;

namespace NReco.Tests.Data {
	
	[TestFixture]
	public class ConstDataSetFactoryTests {

		[Test]
		public void PoolTest() {
			var factoryDs = new ConstDataSetFactory(SampleDsXml, true);

			// get 2 instances, one make dirty
			var ds1 = factoryDs.GetDataSet();
			var ds2 = factoryDs.GetDataSet();
			var ds1Xml = ds1.GetXml();
			var ds2Xml = ds2.GetXml();

			Assert.AreEqual(2, factoryDs.NewInstanceCounter);
			ds2.Tables.Add("bla");

			factoryDs.Dispose();

			factoryDs = new ConstDataSetFactory(SampleDsXml, true);
			
			ds1 = factoryDs.GetDataSet();
			Assert.AreEqual(ds1Xml, ds1.GetXml() );
			
			ds2 = factoryDs.GetDataSet();
			Assert.AreEqual(ds2Xml, ds2.GetXml() );

			Assert.AreEqual(1, factoryDs.NewInstanceCounter);
			factoryDs.Dispose();

			factoryDs = new ConstDataSetFactory(SampleDsXml, true);
			ds1 = factoryDs.GetDataSet();
			Assert.AreEqual(ds1Xml, ds1.GetXml() );
			
			ds2 = factoryDs.GetDataSet();
			Assert.AreEqual(ds2Xml, ds2.GetXml() );
			
			Assert.AreEqual(0, factoryDs.NewInstanceCounter);

			Assert.Catch<System.Data.ReadOnlyException>( () => { ds1.Tables["users"].Rows[0]["name"] = "bla"; } );
		}


		string SampleDsXml = @"
<NewDataSet>
<xs:schema id=""NewDataSet"" xmlns="""" xmlns:xs=""http://www.w3.org/2001/XMLSchema"" xmlns:msdata=""urn:schemas-microsoft-com:xml-msdata"">
    <xs:element name=""NewDataSet"" msdata:IsDataSet=""true"" msdata:UseCurrentLocale=""true"">
      <xs:complexType>
        <xs:choice minOccurs=""0"" maxOccurs=""unbounded"">
          <xs:element name=""users"">
            <xs:complexType>
              <xs:sequence>
                <xs:element name=""id"" type=""xs:int"" />
                <xs:element name=""name"" type=""xs:string"" minOccurs=""0"" />
                <xs:element name=""role"" type=""xs:string"" minOccurs=""0"" />
              </xs:sequence>
            </xs:complexType>
          </xs:element>
          <xs:element name=""roles"">
            <xs:complexType>
              <xs:sequence>
                <xs:element name=""id"" type=""xs:int"" />
                <xs:element name=""role"" type=""xs:string"" minOccurs=""0"" />
              </xs:sequence>
            </xs:complexType>
          </xs:element>
        </xs:choice>
      </xs:complexType>
      <xs:unique name=""Constraint1"" msdata:PrimaryKey=""true"">
        <xs:selector xpath="".//users"" />
        <xs:field xpath=""id"" />
      </xs:unique>
      <xs:unique name=""roles_Constraint1"" msdata:ConstraintName=""Constraint1"" msdata:PrimaryKey=""true"">
        <xs:selector xpath="".//roles"" />
        <xs:field xpath=""id"" />
      </xs:unique>
    </xs:element>
  </xs:schema>
  <users>
    <id>1</id>
    <name>Mike</name>
    <role>1</role>
  </users>
  <users>
    <id>2</id>
    <name>Joe</name>
    <role>1</role>
  </users>
  <users>
    <id>3</id>
    <name>Stas</name>
    <role>2</role>
  </users>
  <roles>
    <id>1</id>
    <role>admin</role>
  </roles>
  <roles>
    <id>2</id>
    <role>user</role>
  </roles>
</NewDataSet>
";
	
	}
}
