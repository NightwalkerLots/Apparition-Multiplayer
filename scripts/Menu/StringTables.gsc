StatsTableType(index)
{
    return TableLookup("gamedata/stats/mp/mp_statstable.csv", 0, index, 2);
}

StatsTableRaw(index)
{
    return TableLookup("gamedata/stats/mp/mp_statstable.csv", 0, index, 4);
}

StatsTableLocalized(index)
{
    return TableLookup("gamedata/stats/mp/mp_statstable.csv", 0, index, 3);
}

StatsTableKillstreakType(index)
{
    return Int(TableLookup("gamedata/stats/mp/mp_statstable.csv", 0, index, 12));
}

ReturnCamoName(index)
{
    return TableLookupColumnForRow("gamedata/weapons/common/attachmenttable.csv", index, 3);
}

ReturnRawCamoName(index)
{
    return TableLookupColumnForRow("gamedata/weapons/common/attachmenttable.csv", index, 4);
}

ReturnAttachmentType(index)
{
    return TableLookup("gamedata/weapons/common/attachmenttable.csv", 0, index, 2);
}

ReturnAttachment(index)
{
    return TableLookup("gamedata/weapons/common/attachmenttable.csv", 0, index, 4);
}

ReturnAttachmentName(attachment)
{
    return TableLookup("gamedata/weapons/common/attachmenttable.csv", 4, attachment, 3);
}

ReturnAttachmentCombinations(attachment)
{
    return TableLookup("gamedata/weapons/common/attachmenttable.csv", 4, attachment, 12);
}