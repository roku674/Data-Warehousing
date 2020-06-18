using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Cryptography;
using System.Text;
using Microsoft.SqlServer.Dts.Pipeline;
using Microsoft.SqlServer.Dts.Pipeline.Wrapper;
using Microsoft.SqlServer.Dts.Runtime.Wrapper;

namespace Microsoft.TK463
{
    /// <summary>
    /// TK 463 Calculate Checksum Transformation
    /// </summary>
    [DtsPipelineComponent(
        ComponentType = ComponentType.Transform,
        Description = "TK 463 Calculate Checksum Transformation",
        DisplayName = "Calculate Checksum"
        )]
    public class CalculateCheckSum : PipelineComponent
    {
        #region Private Properties
        /// <summary>
        /// The hash algorithm to be used.
        /// </summary>
        private HashAlgorithm _hashAlgorithm;

        /// <summary>
        /// The index of the built-in check sum column.
        /// </summary>
        private Int32 _checkSumColumnIndex;

        /// <summary>
        /// String builder used to build the check sum.
        /// </summary>
        private StringBuilder _stringBuilder;
        #endregion

        #region Defaults
        /// <summary>
        /// The name and description of the hash algorithm component property.
        /// </summary>
        private String _hashAlgorithmPropertyName = "HashAlgorithm";
        private String _hashAlgorithmPropertyDescription = "Algorithm to be used for calculating the checksum.";

        /// <summary>
        /// The name and description of the built-in check sum output column.
        /// </summary>
        private String _checkSumColumnName = "_CheckSum";
        private String _checkSumColumnDescription = "Calculated Checksum";

        /// <summary>
        /// The name and description of the built-in column property used to distinguish between built-in and user defined columns.
        /// </summary>
        private String _isInternalPropertyName = "IsInternal";
        private String _isInternalPropertyDescription = "True = This is an internal column of the component, False = This is a user-defined column.";

        /// <summary>
        /// Messages.
        /// </summary>
        private String _errorTooManyInputs = "Only a single input is supported.";
        private String _errorNoInputColumns = "At least one input column must be selected.";
        private String _errorNoHashAlgorithm = "A supported hash algorithm must be selected.";
        private String _errorMissingChecksumColumn = "The built-in check sum output column does not exist.";
        #endregion

        #region Design-time Methods
        /// <summary>
        /// The overridden ProvideComponentProperties method.
        /// </summary>
        public override void ProvideComponentProperties()
        {
            base.ProvideComponentProperties();

            // Create component properties.
            this.CreateCustomProperties();

            // Create Synchronous Output
            IDTSOutput100 output = ComponentMetaData.OutputCollection[0];
            output.SynchronousInputID = ComponentMetaData.InputCollection[0].ID;

            // Create built-in output columns.
            this.CreateOutputColumns(ref output);
        }

        /// <summary>
        /// The overridden Validate method.
        /// </summary>
        /// <returns></returns>
        public override DTSValidationStatus Validate()
        {
            Boolean pbCancel;
            // Only one input is allowed.
            if (ComponentMetaData.InputCollection.Count > 1)
            {
                ComponentMetaData.FireError(0, ComponentMetaData.Name, _errorTooManyInputs, null, 0, out pbCancel);
                return DTSValidationStatus.VS_ISBROKEN;
            }

            // At least one input column must be selected.
            if (ComponentMetaData.InputCollection[0].InputColumnCollection.Count < 1)
            {
                ComponentMetaData.FireError(0, ComponentMetaData.Name, _errorNoInputColumns, null, 0, out pbCancel);
                return DTSValidationStatus.VS_ISBROKEN;
            }

            // A valid hash Algorithm must be selected.
            SupportedHashAlgorithm selectedHashAlgorithm = (SupportedHashAlgorithm)ComponentMetaData.CustomPropertyCollection[_hashAlgorithmPropertyName].Value;
            if (String.IsNullOrEmpty(selectedHashAlgorithm.ToString()))
            {
                ComponentMetaData.FireError(0, ComponentMetaData.Name, _errorNoHashAlgorithm, null, 0, out pbCancel);
                return DTSValidationStatus.VS_ISBROKEN;
            }

            // The built-in check sum column must not be missing.
            IDTSOutput100 _output = ComponentMetaData.OutputCollection[0];
            List<IDTSOutputColumn100> outputColumnList = new List<IDTSOutputColumn100>();
            outputColumnList.AddRange
                (
                    _output.OutputColumnCollection.Cast<IDTSOutputColumn100>()
                );
            if (!outputColumnList.Exists(outputColumn => outputColumn.Name == _checkSumColumnName))
            {
                ComponentMetaData.FireError(0, ComponentMetaData.Name, _errorMissingChecksumColumn, null, 0, out pbCancel);
                return DTSValidationStatus.VS_ISCORRUPT;
            }

            return base.Validate();
        }

        /// <summary>
        /// The overridden DeleteOutputColumn method.
        /// </summary>
        /// <param name="outputID"></param>
        /// <param name="outputColumnID"></param>
        public override void DeleteOutputColumn(int outputID, int outputColumnID)
        {
            // Only allow the removal of user-defined output columns.
            if (!(Boolean)ComponentMetaData.OutputCollection.GetObjectByID(outputID).OutputColumnCollection.GetObjectByID(outputColumnID).CustomPropertyCollection[_isInternalPropertyName].Value)
                base.DeleteOutputColumn(outputID, outputColumnID);
        }
        #endregion

        #region Run-time Methods
        /// <summary>
        /// The overridden PrepareForExecute method.
        /// </summary>
        public override void PrepareForExecute()
        {
            // Assign internal variables.
           
            // Create a string builder to be used later.
            _stringBuilder =  new StringBuilder();

            // Create a hash algorithm based on the value in the hash algorithm
            // component property.
            SupportedHashAlgorithm selectedHashAlgorithm = (SupportedHashAlgorithm)ComponentMetaData.CustomPropertyCollection[_hashAlgorithmPropertyName].Value;
            String selectedHashAlgorithmName = selectedHashAlgorithm.ToString();
            _hashAlgorithm = HashAlgorithm.Create(selectedHashAlgorithmName);

            base.PrepareForExecute();
        }

        /// <summary>
        /// The overridden PreExecute method.
        /// </summary>
        public override void PreExecute()
        {
            // Retrieve the index of the built-in check sum column.
            IDTSOutput100 _output = ComponentMetaData.OutputCollection[0];
            List<IDTSOutputColumn100> outputColumnList = new List<IDTSOutputColumn100>();
            outputColumnList.AddRange
                (
                    _output.OutputColumnCollection.Cast<IDTSOutputColumn100>()
                );
            _checkSumColumnIndex = BufferManager.FindColumnByLineageID
                (
                    ComponentMetaData.InputCollection[0].Buffer,
                    outputColumnList.First<IDTSOutputColumn100>
                        (
                            outputColumn => outputColumn.Name == _checkSumColumnName
                        ).LineageID
                );

            base.PreExecute();
        }

        /// <summary>
        /// The overridden ProcessInput method.
        /// </summary>
        /// <param name="inputID"></param>
        /// <param name="buffer"></param>
        public override void ProcessInput(int inputID, PipelineBuffer buffer)
        {
            // Validation guarantees that only one input will be connected.
            IDTSInput100 input = ComponentMetaData.InputCollection.FindObjectByID(inputID);
            List<Byte> valueList = new List<Byte>();
            String hashValue = String.Empty;

            // Retrieve a new row from the input buffer...
            while (buffer.NextRow())
            {
                // ...retrieve values from each column...
                foreach (IDTSInputColumn100 inputColumm in input.InputColumnCollection)
                {
                    // ...add binary representation of column values to the
                    // internal list of values.
                    valueList.AddRange
                        (
                            this.GetBytes
                                (
                                    inputColumm.DataType,
                                    input.InputColumnCollection.GetObjectIndexByID
                                        (
                                            inputColumm.ID
                                        ),
                                    ref buffer
                                )
                        );
                }

                // Calculate a hash value using the data from the entire row.
                hashValue = this.CreateCheckSum(valueList.ToArray());

                // Write the hash value to the built-in check sum column.
                buffer.SetString(_checkSumColumnIndex, hashValue);

                // Clear internal variables.
                valueList.Clear();
                hashValue = String.Empty;
            }
        }

        /// <summary>
        /// The overridden PostExecute method.
        /// </summary>
        public override void PostExecute()
        {
            // Release resources.
            _hashAlgorithm.Dispose();

            base.PostExecute();
        }
        #endregion

        #region Private methods
        /// <summary>
        /// Create component properties.
        /// </summary>
        private void CreateCustomProperties()
        {
            // Hash algorithm property.
            IDTSCustomProperty100 hashAlgorithm = ComponentMetaData.CustomPropertyCollection.New();
            hashAlgorithm.Name = _hashAlgorithmPropertyName;
            hashAlgorithm.Description = _hashAlgorithmPropertyDescription;
            hashAlgorithm.TypeConverter = typeof(SupportedHashAlgorithm).AssemblyQualifiedName;
            hashAlgorithm.Value = SupportedHashAlgorithm.RIPEMD160;
        }

        /// <summary>
        /// Create built-in output columns.
        /// </summary>
        /// <param name="output"></param>
        private void CreateOutputColumns()
        {
            IDTSOutput100 output = ComponentMetaData.OutputCollection[0];
            this.CreateOutputColumns(ref output);
        }
        private void CreateOutputColumns(ref IDTSOutput100 output)
        {
            // Check sum column (internal, and cannot be removed).
            IDTSOutputColumn100 _hashValueColumn = output.OutputColumnCollection.New();
            _hashValueColumn.SetDataTypeProperties(DataType.DT_STR, 128, 0, 0, 1252);
            _hashValueColumn.Name = _checkSumColumnName;
            _hashValueColumn.Description = _checkSumColumnDescription;
            IDTSCustomProperty100 isInternal = _hashValueColumn.CustomPropertyCollection.New();
            isInternal.Name = _isInternalPropertyName;
            isInternal.Description = _isInternalPropertyDescription;
            isInternal.Value = true;
            isInternal.TypeConverter = typeof(Boolean).AssemblyQualifiedName;
        }

        /// <summary>
        /// Get binary data from the selected column in the buffer, in accordance with the columns data type.
        /// </summary>
        /// <param name="dataType">The data type of the column.</param>
        /// <param name="columnIndex">The index of the column.</param>
        /// <param name="buffer">The reference to the input buffer.</param>
        /// <returns></returns>
        private Byte[] GetBytes(DataType dataType, int columnIndex, ref PipelineBuffer buffer)
        {
            String value = String.Empty;

            if (!buffer.IsNull(columnIndex))
            {
                switch (dataType)
                {
                    // Extract data from the column, based on the column data type.
                    #region Extract Data
                    case DataType.DT_BOOL:
                        value = buffer.GetBoolean(columnIndex).ToString();
                        break;
                    case DataType.DT_BYTES:
                        return buffer.GetBytes(columnIndex);
                    case DataType.DT_DBDATE:
                        value = buffer.GetDate(columnIndex).ToString();
                        break;
                    case DataType.DT_DBTIME:
                    case DataType.DT_DBTIME2:
                        value = buffer.GetTime(columnIndex).ToString();
                        break;
                    case DataType.DT_DATE:
                    case DataType.DT_DBTIMESTAMP:
                    case DataType.DT_DBTIMESTAMP2:
                    case DataType.DT_FILETIME:
                        value = buffer.GetDateTime(columnIndex).ToString();
                        break;
                    case DataType.DT_DBTIMESTAMPOFFSET:
                        value = buffer.GetDateTimeOffset(columnIndex).ToString();
                        break;
                    case DataType.DT_DECIMAL:
                    case DataType.DT_NUMERIC:
                    case DataType.DT_CY:
                        value = buffer.GetDecimal(columnIndex).ToString();
                        break;
                    case DataType.DT_GUID:
                        value = buffer.GetGuid(columnIndex).ToString();
                        break;
                    case DataType.DT_I1:
                        value = buffer.GetSByte(columnIndex).ToString();
                        break;
                    case DataType.DT_I2:
                        value = buffer.GetInt16(columnIndex).ToString();
                        break;
                    case DataType.DT_I4:
                        value = buffer.GetInt32(columnIndex).ToString();
                        break;
                    case DataType.DT_I8:
                        value = buffer.GetInt64(columnIndex).ToString();
                        break;
                    case DataType.DT_IMAGE:
                    case DataType.DT_NTEXT:
                    case DataType.DT_TEXT:
                        return buffer.GetBlobData(columnIndex, (Int32)0, (Int32)buffer.GetBlobLength(columnIndex));
                    case DataType.DT_R4:
                        value = buffer.GetSingle(columnIndex).ToString();
                        break;
                    case DataType.DT_R8:
                        value = buffer.GetDouble(columnIndex).ToString();
                        break;
                    case DataType.DT_STR:
                    case DataType.DT_WSTR:
                        value = buffer.GetString(columnIndex);
                        break;
                    case DataType.DT_UI1:
                        value = buffer.GetByte(columnIndex).ToString();
                        break;
                    case DataType.DT_UI2:
                        value = buffer.GetUInt16(columnIndex).ToString();
                        break;
                    case DataType.DT_UI4:
                        value = buffer.GetUInt32(columnIndex).ToString();
                        break;
                    case DataType.DT_UI8:
                        value = buffer.GetUInt64(columnIndex).ToString();
                        break;
                    default:
                        value = String.Empty;
                        break;
                    #endregion
                }
            }

            return Encoding.Unicode.GetBytes(value);
        }

        /// <summary>
        /// Create check sum from row data.
        /// </summary>
        /// <param name="values"></param>
        /// <returns></returns>
        private String CreateCheckSum(Byte[] values)
        {
            Byte[] hashBytes;
            _stringBuilder.Clear();

            // Compute hash using previously created algorithm.
            hashBytes = _hashAlgorithm.ComputeHash(values);

            // Create a two-byte hexadecimal string representation of the byte array using the string builder created earlier.
            for (int i = 0; i < hashBytes.Length; i++)
			{
                _stringBuilder.Append(hashBytes[i].ToString("X2"));
			}

            return _stringBuilder.ToString();
        }
        #endregion

        #region Enumerations
        /// <summary>
        /// Enumeration of supported hashing algorithm names.
        /// The following algorithms are supported by the System.Security.Cryptography.HashAlgorithm.
        /// </summary>
        public enum SupportedHashAlgorithm
        {
            MD5,
            RIPEMD160,
            SHA1,
            SHA256,
            SHA384,
            SHA512
        }
        #endregion
    }
}
