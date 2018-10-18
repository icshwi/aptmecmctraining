program example

float VAL;
assign VAL to "jparc:002.VAL";
monitor VAL;

short OUPIN_16;
assign OUPIN_16 to "jparc:ec0-s2-EL2819-BO16";

ss VAL_check
{
	state VAL_good
	{
		when (VAL>200)
		{
		OUPIN_16=TRUE;
		pvput(OUPIN_16);
		}state VAL_bad
	}

	state VAL_bad
	{
		when (VAL<200)
		{	
		OUPIN_16=FALSE;
		pvPut(OUPIN_16);
		}
	} state VAL_good
}
