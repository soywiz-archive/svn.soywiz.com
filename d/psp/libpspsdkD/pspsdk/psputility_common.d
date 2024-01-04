module pspsdk.psputility_common;

struct pspUtilityDialogCommon
{
	uint size;			/** Size of the structure */
	int language;		/** Language */
	int buttonSwap;		/** Set to 1 for X/O button swap */
	int graphicsThread;	/** Graphics thread priority */
	int accessThread;	/** Access/fileio thread priority (SceJobThread) */
	int fontThread;		/** Font thread priority (ScePafThread) */
	int soundThread;	/** Sound thread priority */
	int result;			/** Result */
	int reserved[4];	/** Set to 0 */

}

const int PSP_UTILITY_ACCEPT_CIRCLE = 0;
const int PSP_UTILITY_ACCEPT_CROSS =  1;

/**
 * Return-values for the various sceUtility***GetStatus() functions
**/
enum pspUtilityDialogState
{
	PSP_UTILITY_DIALOG_NONE = 0,	/**< No dialog is currently active */
	PSP_UTILITY_DIALOG_INIT,		/**< The dialog is currently being initialized */
	PSP_UTILITY_DIALOG_VISIBLE,		/**< The dialog is visible and ready for use */
	PSP_UTILITY_DIALOG_QUIT,		/**< The dialog has been canceled and should be shut down */
	PSP_UTILITY_DIALOG_FINISHED		/**< The dialog has successfully shut down */
	
};


