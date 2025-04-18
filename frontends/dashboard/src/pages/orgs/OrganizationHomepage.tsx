import { DatasetOverview } from "../../components/DatasetOverview";
import { GettingStartedDocsLinks } from "../../components/GettingStartedDocsLinks";
import { OnboardingSteps } from "../../components/OnboardingSteps";
import OrgUpdateAlert from "../../components/OrgUpdateAlert";
import { TopComponents } from "../../components/TopComponents";
import { TrieveMaintenanceAlert } from "../../components/TrieveMaintenanceAlert";
import { useContext } from "solid-js";
import { UserContext } from "../../contexts/UserContext";

export const OrganizationHomepage = () => {
  const userContext = useContext(UserContext);
  const orgId = () => userContext.selectedOrg().id;

  return (
    <div class="pb-8">
      {import.meta.env.VITE_MAINTENANCE_ON == "true" && (
        <TrieveMaintenanceAlert />
      )}
      <div class="h-1" />
      <OrgUpdateAlert />
      <div class="h-1" />
      <OnboardingSteps />
      <div class="h-1" />
      <DatasetOverview />
      <div class="h-6" />
      <TopComponents orgId={orgId()} />
      <div class="h-6" />
      <GettingStartedDocsLinks />
    </div>
  );
};
