using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Navigation;
using System.Windows.Shapes;
using System.Windows.Threading;

using CLIPSNET;

namespace VMatch
{
    public partial class MainWindow : Window
    {
        private class VWORecommendation
        {
            public string VwoName { get; set; }
            public int Certainty { get; set; }
            public string CertaintyText { get; set; }
            public string CertaintyWidthTaken { get; set; }
            public string CertaintyWidthLeft { get; set; }
        }

        String[] preferredFrequencyNames = { "Don't Care", "AdHoc", "Annually" };
        String[] preferredOrgTypeNames = { "Don't Care", "Medical", "SocialSvc.Women", "SocialSvc.Children", "Animal", "Sports"};
        String[] preferredAreaNames = { "Don't Care", "North", "NorthEast", "East", "South", "West" };
        String[] preferredDurationNames = { "Don't Care", "4hrs or less", "Whole day" };

        String[] causesNames = { "Don't Know", "Elderly", "Health", "Community", "Disability", "Children", "Youth", "Social Service", "Other" };
        String[] dayNames = { "No Preference", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday", "Any Weekday", "Any Weekend" };
        String[] locationNames = { "No Preference", "Islandwide", "Ang Mo Kio", "Bedok", "Bishan", "Boon Lay", "Bukit Batok", "Bukit Merah", "Bukit Pangjang", "Bukit Timah", "Choa Chu Kang",
                                    "Downtown Core", "Geylang", "Hougang", "Jurong East", "Kallang", "Novena", "Orchard", "Outram", "Paya Lebar", "Pioneer", "Punggol", "Queenstown",
                                    "River Valley", "Rochor", "Sembawang", "Sengkang", "Serangoon", "Tampines", "Tanglin", "Toa Payoh", "Woodlands", "Yishun"  };

        String[] agegroupNames = { "Private", "16-20", "21-35", "36-54", "55 onwards", "Other" };
        String[] skillNames = { "None", "First Aid", "CPR", "IT", "Special Needs", "Early Childhood", "Medical", "Other" };
        String[] a_valuesNames = { "Don't Know", "ABC", "XYZ" };

        String[] preferredFrequencyChoices;
        String[] preferredOrgTypeChoices;
        String[] preferredAreaChoices;
        String[] preferredDurationChoices;

        String[] causesChoices;
        String[] dayChoices;
        String[] locationChoices;

        String[] agegroupChoices;
        String[] skillChoices;
        String[] a_valuesChoices;

        private CLIPSNET.Environment clips;
        private bool formLoaded = false;

        public MainWindow()
        {
            Dispatcher.BeginInvoke(DispatcherPriority.Loaded, new Action(() => { OnLoad(); }));
            InitializeComponent();
            clips = new CLIPSNET.Environment();
            clips.LoadFromResource("VMatch", "VMatch.volunteer.clp");
        }

        private String[] GenerateChoices(
          String[] names)
        {
            String[] choices = new String[names.Count()];

            for (int i = 0; i < names.Count(); i++)
            { choices[i] = names[i]; }

            return choices;
        }

        private void OnLoad()
        {
            RunVWO();
            formLoaded = true;
        }

        private void FrequencyComboBox_Loaded(object sender, RoutedEventArgs e)
        {
            preferredFrequencyChoices = GenerateChoices(preferredFrequencyNames);

            var frequencyComboBox = sender as ComboBox;

            frequencyComboBox.ItemsSource = preferredFrequencyChoices;

            frequencyComboBox.SelectedIndex = 0;
        }

        private void OrgTypeComboBox_Loaded(object sender, RoutedEventArgs e)
        {
            preferredOrgTypeChoices = GenerateChoices(preferredOrgTypeNames);

            var orgtypeComboBox = sender as ComboBox;

            orgtypeComboBox.ItemsSource = preferredOrgTypeChoices;

            orgtypeComboBox.SelectedIndex = 0;
        }

        private void AreaComboBox_Loaded(object sender, RoutedEventArgs e)
        {
            preferredAreaChoices = GenerateChoices(preferredAreaNames);

            var areaComboBox = sender as ComboBox;

            areaComboBox.ItemsSource = preferredAreaChoices;

            areaComboBox.SelectedIndex = 0;
        }

        private void DurationComboBox_Loaded(object sender, RoutedEventArgs e)
        {
            preferredDurationChoices = GenerateChoices(preferredDurationNames);

            var durationComboBox = sender as ComboBox;

            durationComboBox.ItemsSource = preferredDurationChoices;

            durationComboBox.SelectedIndex = 0;
        }

        private void CausesComboBox_Loaded(object sender, RoutedEventArgs e)
        {
            causesChoices = GenerateChoices(causesNames);

            var causesComboBox = sender as ComboBox;

            causesComboBox.ItemsSource = causesChoices;

            causesComboBox.SelectedIndex = 0;
        }

        private void DayComboBox_Loaded(object sender, RoutedEventArgs e)
        {
            dayChoices = GenerateChoices(dayNames);

            var dayComboBox = sender as ComboBox;

            dayComboBox.ItemsSource = dayChoices;

            dayComboBox.SelectedIndex = 0;
        }

        // Location selection and clips assert to location hard to work until we can assign a variable to "locationChoices" in CLIPS.

        private void LocationComboBox_Loaded(object sender, RoutedEventArgs e)
        {
            locationChoices = GenerateChoices(locationNames);

            var locationComboBox = sender as ComboBox;

            locationComboBox.ItemsSource = locationChoices;

            locationComboBox.SelectedIndex = 0;
        }

        private void AgeGroupComboBox_Loaded(object sender, RoutedEventArgs e)
        {
            agegroupChoices = GenerateChoices(agegroupNames);

            var agegroupComboBox = sender as ComboBox;

            agegroupComboBox.ItemsSource = agegroupChoices;

            agegroupComboBox.SelectedIndex = 0;
        }

        private void SkillComboBox_Loaded(object sender, RoutedEventArgs e)
        {
            skillChoices = GenerateChoices(skillNames);

            var skillComboBox = sender as ComboBox;

            skillComboBox.ItemsSource = skillChoices;

            skillComboBox.SelectedIndex = 0;
        }

        private void a_ValuesComboBox_Loaded(object sender, RoutedEventArgs e)
        {
            a_valuesChoices = GenerateChoices(a_valuesNames);

            var a_valuesComboBox = sender as ComboBox;

            a_valuesComboBox.ItemsSource = a_valuesChoices;

            a_valuesComboBox.SelectedIndex = 0;
        }

        private void OnChange(object sender, SelectionChangedEventArgs e)
        {
            if (formLoaded)
            { RunVWO(); }
        }

        private void RunVWO()
        {
            clips.Reset();

            string item = (string)frequencyComboBox.SelectedValue;

            if (item.Equals("Adhoc"))
            { clips.AssertString("(attribute (name preferred-freq) (value adhoc))"); }
            else if (item.Equals("Annually"))
            { clips.AssertString("(attribute (name preferred-freq) (value annually))"); }
            else
            { clips.AssertString("(attribute (name preferred-freq) (value unknown))"); }

            item = (string)orgtypeComboBox.SelectedValue;

            if (item.Equals("Medical"))
            { clips.AssertString("(attribute (name preferred-orgtype) (value medical))"); }
            else if (item.Equals("SocialSvc.Children"))
            { clips.AssertString("(attribute (name preferred-orgtype) (value ss.children))"); }
            else if (item.Equals("SocialSvc.Women"))
            { clips.AssertString("(attribute (name preferred-orgtype) (value ss.women))"); }
            else if (item.Equals("Animal"))
            { clips.AssertString("(attribute (name preferred-orgtype) (value animal))"); }
            else if (item.Equals("Sports"))
            { clips.AssertString("(attribute (name preferred-orgtype) (value sports))"); }
            else
            { clips.AssertString("(attribute (name preferred-orgtype) (value unknown))"); }

            item = (string)areaComboBox.SelectedValue;

            if (item.Equals("North"))
            { clips.AssertString("(attribute (name preferred-area) (value north))"); }
            else if (item.Equals("NorthEast"))
            { clips.AssertString("(attribute (name preferred-area) (value northeast))"); }
            else if (item.Equals("East"))
            { clips.AssertString("(attribute (name preferred-area) (value east))"); }
            else if (item.Equals("South"))
            { clips.AssertString("(attribute (name preferred-area) (value south))"); }
            else if (item.Equals("West"))
            { clips.AssertString("(attribute (name preferred-area) (value west))"); }
            else
            { clips.AssertString("(attribute (name preferred-area) (value unknown))"); }

            item = (string)durationComboBox.SelectedValue;

            if (item.Equals("4hrs or less"))
            { clips.AssertString("(attribute (name preferred-duration) (value halfdayless))"); }
            else if (item.Equals("Whole day"))
            { clips.AssertString("(attribute (name preferred-duration) (value wholeday))"); }
            else
            { clips.AssertString("(attribute (name preferred-duration) (value unknown))"); }

            item = (string)causesComboBox.SelectedValue;

            if (item.Equals("Elderly") ||
                item.Equals("Social Service"))
            {
                clips.AssertString("(attribute (name p-cause) (value socialservice))");
                clips.AssertString("(attribute (name has-turkey) (value no))");
            }
            else if (item.Equals("Health"))
            {
                clips.AssertString("(attribute (name p-cause) (value health))");
                clips.AssertString("(attribute (name has-turkey) (value yes))");
            }
            else if (item.Equals("Community"))
            {
                clips.AssertString("(attribute (name p-cause) (value community))");
                clips.AssertString("(attribute (name has-turkey) (value no))");
            }
            else if (item.Equals("Disability"))
            {
                clips.AssertString("(attribute (name p-cause) (value disability))");
                clips.AssertString("(attribute (name has-turkey) (value no))");
            }
            else if (item.Equals("Children"))
            {
                clips.AssertString("(attribute (name p-cause) (value children))");
                clips.AssertString("(attribute (name has-turkey) (value no))");
            }
            else if (item.Equals("Youth"))
            {
                clips.AssertString("(attribute (name p-cause) (value youth))");
                clips.AssertString("(attribute (name has-turkey) (value no))");
            }
            else if (item.Equals("Social Service"))
            {
                clips.AssertString("(attribute (name p-cause) (value socialservice))");
                clips.AssertString("(attribute (name has-turkey) (value no))");
            }
            else if (item.Equals("Other"))
            {
                clips.AssertString("(attribute (name p-cause) (value unknown))");
                clips.AssertString("(attribute (name has-turkey) (value no))");
            }
            else
            {
                clips.AssertString("(attribute (name p-cause) (value unknown))");
                clips.AssertString("(attribute (name has-turkey) (value unknown))");
            }

            item = (string)dayComboBox.SelectedValue;

            if (item.Equals("None"))
            { clips.AssertString("(attribute (name has-sauce) (value no))"); }
            else if (item.Equals("Spicy"))
            {
                clips.AssertString("(attribute (name has-sauce) (value yes))");
                clips.AssertString("(attribute (name sauce) (value spicy))");
            }
            else if (item.Equals("Sweet"))
            {
                clips.AssertString("(attribute (name has-sauce) (value yes))");
                clips.AssertString("(attribute (name sauce) (value sweet))");
            }
            else if (item.Equals("Cream"))
            {
                clips.AssertString("(attribute (name has-sauce) (value yes))");
                clips.AssertString("(attribute (name sauce) (value cream))");
            }
            else if (item.Equals("Other"))
            {
                clips.AssertString("(attribute (name has-sauce) (value yes))");
                clips.AssertString("(attribute (name sauce) (value unknown))");
            }
            else
            {
                clips.AssertString("(attribute (name has-sauce) (value unknown))");
                clips.AssertString("(attribute (name sauce) (value unknown))");
            }

            // Location selection and clips assert to location hard to work until we can assign a variable to "locationChoices" in CLIPS.

            item = (string)locationComboBox.SelectedValue;
            if (item.Equals("No Preference"))
            { clips.AssertString("(attribute (name preferred-location) (value unknown))"); }
            else
            { clips.AssertString("(attribute (name preferred-location) (value ))"); }

            item = (string)agegroupComboBox.SelectedValue;
            if (item.Equals("16-20"))
            { clips.AssertString("(attribute (name agegroup) (value 16-20))"); }
            else if (item.Equals("21-35"))
            { clips.AssertString("(attribute (name agegroup) (value 21-35))"); }
            else if (item.Equals("36-54"))
            { clips.AssertString("(attribute (name agegroup) (value 36-54))"); }
            else if (item.Equals("55 onwards"))
            { clips.AssertString("(attribute (name agegroup) (value 55plus))"); }
            else if (item.Equals("Other"))
            { clips.AssertString("(attribute (name agegroup) (value other))"); }
            else
            { clips.AssertString("(attribute (name agegroup) (value unknown))"); }

            item = (string)skillComboBox.SelectedValue;
            if (item.Equals("First Aid"))
            { clips.AssertString("(attribute (name skill) (value firstaid))"); }
            else if (item.Equals("CPR"))
            { clips.AssertString("(attribute (name skill) (value cpr))"); }
            else if (item.Equals("IT"))
            { clips.AssertString("(attribute (name skill) (value infotech))"); }
            else if (item.Equals("Special Needs"))
            { clips.AssertString("(attribute (name skill) (value specialneeds))"); }
            else if (item.Equals("Early Childhood"))
            { clips.AssertString("(attribute (name skill) (value earlychild))"); }
            else if (item.Equals("Medical"))
            { clips.AssertString("(attribute (name skill) (value medical))"); }
            else if (item.Equals("Other"))
            { clips.AssertString("(attribute (name skill) (value other))"); }
            else
            { clips.AssertString("(attribute (name skill) (value unknown))"); }

            item = (string)a_valuesComboBox.SelectedValue;
            if (item.Equals("ABC"))
            { clips.AssertString("(attribute (name a_values) (value abc))"); }
            else if (item.Equals("XYZ"))
            { clips.AssertString("(attribute (name a_values) (value xyz))"); }
            else
            { clips.AssertString("(attribute (name a_values) (value unknown))"); }

            clips.Run();

            UpdateVWOs();
        }

        private void UpdateVWOs()
        {
            string evalStr = "(VWOs::get-vwo-list)";
            List<VWORecommendation> vwoList = new List<VWORecommendation>();

            foreach (FactAddressValue fv in clips.Eval(evalStr) as MultifieldValue)
            {
                int certainty = (int)(((NumberValue)fv["certainty"]));

                String vwoName = ((LexemeValue)fv["value"]).Value;

                vwoList.Add(new VWORecommendation()
                {
                    VwoName = vwoName,
                    Certainty = certainty,
                    CertaintyText = certainty + "%",
                    CertaintyWidthTaken = certainty + "*",
                    CertaintyWidthLeft = (100 - certainty) + "*"
                });
            }

            resultsDataGridView.ItemsSource = vwoList;
        }

        private void Button_Click(object sender, RoutedEventArgs e)
        {
            frequencyComboBox.SelectedIndex = 0;
			orgtypeComboBox.SelectedIndex = 0;
			areaComboBox.SelectedIndex = 0;
			durationComboBox.SelectedIndex = 0;
			causesComboBox.SelectedIndex = 0;
			dayComboBox.SelectedIndex = 0;
			locationComboBox.SelectedIndex = 0;
			agegroupComboBox.SelectedIndex = 0;
			skillComboBox.SelectedIndex = 0;
			a_valuesComboBox.SelectedIndex = 0;
        }
    }
}
